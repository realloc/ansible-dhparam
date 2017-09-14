#!/usr/bin/python
# -*- coding: utf-8 -*-
#

from ansible.module_utils.basic import *

DOCUMENTATION = '''
---
module: dhparam
author: "Stanislav Bogatyrev <realloc@realloc.spb.ru>"
version_added: "2.0"
short_description: Manage Diffie-Hellman parameters file
description:
  - Manage Diffie-Hellman parameters file
options:
  path:
    description:
      path where dhparam file should be
    required: true
  length:
    description:
      Diffie-Hellman parameter size in bits
    required: false
    default: 2048
  name:
    description:
      dhparam file name
    required: false
    default: dhparam.pem
  expires:
    description:
      Regenerate key if it's mtime/ctime is that old.
      Default is one month (60*60*24*30)
    required: false
    default: 2592000
requirements: []
'''

EXAMPLES = '''
- name: "dhparam"
  dhparam: path="/etc/pki/dhparam/" name="dh2048.pem"
'''


def is_dh_file_ok(self, filename):
    # Check if file exists
    if not (os.path.exists(filename) and os.path.isfile(filename)):
        return False

    # Check if dhparams file has valid content
    (rc, out, err) = self.run_command(
        'openssl dhparam -check -noout -text -in ' +
        filename)
    if out.find('DH parameters appear to be ok') == -1:
        return False

    # Check if dhparams file has correct length
    dh_len = re.search('DH Parameters: \((\d+) bit\)', out).group(1)
    if not int(dh_len) == int(self.params['length']):
        return False

    # Check if dhparams file is not rotten
    mtime = os.path.getmtime(filename)
    if time.time() - mtime > self.params['expires']:
        return False

    return True


def main():
    module = AnsibleModule(
        argument_spec=dict(
            path=dict(
                required=True,
                type='path'
            ),
            length=dict(
                required=False,
                type='int',
                default=2048
            ),
            name=dict(
                required=False,
                type='str',
                default='dhparam.pem'
            ),
            expires=dict(
                required=False,
                type='int',
                default=2592000
            )
        ),
        supports_check_mode=True
    )

    changed = False
    path = os.path.normcase(module.params['path'])
    name = os.path.normcase(module.params['name'])
    filename = os.path.join(path, name)

    # Generate new dhparams if needed
    if not is_dh_file_ok(module, filename):
        # Do nothing in check mode
        if module.check_mode:
            module.exit_json(changed=True, filename=filename)
            # Call openssl to generate DH params
        (rc, out, err) = module.run_command(
            'openssl dhparam ' +
            ' -out ' +
            filename +
            ' ' +
            str(module.params['length'])
        )
        if rc == 0:
            changed = True
        else:
            module.fail_json(
                filename=filename,
                msg='Failed to generate dhparams file: %s' % err)

    module.exit_json(changed=changed, filename=filename)

main()
