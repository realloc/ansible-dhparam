def test_dhparam_file(File):
    dhparam = File('/etc/nginx/ssl/dh1024.pem')
    assert dhparam.exists
