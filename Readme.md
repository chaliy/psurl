PsUrl Utils
=============

Set of commands ( right now only one :) ) to download from web.


Example
=======

For example to download stuff from http://example.com execute

    get-url http://example.com

You can also use pipes

    get-url http://example.com | set-content example.html
    
Using pipes actully allows running scripts directly from web

    get-url https://gist.github.com/raw/909561/hello_world.ps1 | invoke-expression


Installation
============

If you have <a href="https://github.com/chaliy/psget">PsGet</a> installed, you can execute:

    install-module https://github.com/chaliy/psurl/raw/master/PsUrl/PsUrl.psm1
    
Or manual steps

    1. Copy PsUrl.psm1 to your modules folder (e.g. $Env:PSModulePath\PsUrl\ )
    2. Execute Import-Module PsUrl (or add this command to your profile)
    3. Enjoy!