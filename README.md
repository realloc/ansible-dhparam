dhparam
=======

Manage Diffie-Hellman parameters file.
Inspired by [debops.dhparam](https://github.com/debops/ansible-dhparam) role.
Makefile for environment creation taken from [bborysenko/ansible-playbooks](https://github.com/bborysenko/ansible-playbooks).

Requirements
------------

* openssl cli tools installed on target node

Role Variables
--------------

Here is a list of all the default variables for this role, which are also available in `defaults/main.yml`.

```yaml
# Default Diffie-Hellman parameter size in bits
dhparam_length: 2048

# Directory on the managed hosts where Diffie-Hellman parameter sets are kept
# and maintained.
dhparam_path: '/etc/pki/dhparam/'

# Default Diffie-Hellman parameter size in bits
dhparam_name: 'dhparam.pem'

# Regenerate key if it's mtime/ctime is that old
dhparam_expires: 2592000 # 60*60*24*30

```

Examples
--------

Generate dhparams for nginx.

```yaml
  roles:
    - role: dhparam
      dhparam_path: '/etc/nginx/ssl/'
      dhparam_name: 'dh2048.pem'
      dhparam_length: 2048
```

Dependencies
------------

None

License
-------

GPLv3

Author Information
------------------

Stanislav Bogatyrev <realloc@realloc.spb.ru>
