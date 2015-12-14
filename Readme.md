# PsUrl Utils

Set of commands to download and post to web

# Features

1. Download content from any URL as a string
3. POST url encoded form to any URL
3. POST arbitrary requests to any URL

# Examples

For example, to download stuff from http://example.com, execute

    get-webcontent http://example.com

You can also use pipes

    get-webcontent http://example.com | set-content example.html
    
Using pipes actully allows running scripts directly from the web

    get-webcontent https://gist.github.com/raw/909561/hello_world.ps1 | invoke-expression

And of course, you can POST content

    send-webcontent "http://example.com" -Data @{"Foo" = "Bar"}


# Installation

If you have [PsGet](https://github.com/psget/psget) installed, you can execute:

    install-module PsUrl
    
which should output something like this:

    "C:\Users\[User]\Documents\WindowsPowerShell\Modules" is added to the PSModulePath environment variable
    Module PsUrl was successfully installed.

Alternatively, here are the manual steps

    1. Copy PsUrl.psm1 to your modules folder (e.g. $Env:PSModulePath\PsUrl\ )
    2. Execute Import-Module PsUrl (or add this command to your profile)
    3. Enjoy!

# License

This project is licensed under the terms of the MIT license.
