PsUrl Utils
=============

Set of commands to download and post to web

Features
========

1. Download content from any URL as a string
2. Download content from any URL to file
3. POST url encoded form to any URL

Example
=======

For example to download stuff from http://example.com execute

    get-url http://example.com

You can also use pipes

    get-url http://example.com | set-content example.html
    
Using pipes actully allows running scripts directly from web

    get-url https://gist.github.com/raw/909561/hello_world.ps1 | invoke-expression

Another option is to download to file

    get-url http://example.com -ToFile "example.html"

Installation
============

If you have <a href="https://github.com/chaliy/psget">PsGet</a> installed, you can execute:

    install-module https://github.com/chaliy/psurl/raw/master/PsUrl/PsUrl.psm1
    
Or manual steps

    1. Copy PsUrl.psm1 to your modules folder (e.g. $Env:PSModulePath\PsUrl\ )
    2. Execute Import-Module PsUrl (or add this command to your profile)
    3. Enjoy!