salt-vagrant
============

## If (You are doing something like this)

You are using salt to provision / manage your service. You have more than one developer / devops| ops engineer / system admin (how ever you like to call) working on salt formulas. You use github for code management. You also use cloud (IaaS) to test your code.

## and (you have this problem)

You are actively developing salt formulas and you want to be able to test these without waiting others or without worrying about breaking what other have done. You should do 

* fork the main repo
* cofigure / upload your key's to your account so you can pull/push code
* install and configure a salt master
* copy your keys to salt master server
* configure salt-cloud, credentials, server types etc..
* checkout your fork to your own salt master
* create a branch
* work on the code
* run it several times to see how your code is doing
* create a pull request
* get someone approve your pull request
* have your code run in production

Since you use Salt, I assume you like automation so let's automate salt-master section.

* install and configure a salt master
* configure salt-cloud
* checkout your fork to your own salt master

We want this to be so easy that, we won't have to keep any server up longer than the time it takes to do the development.

## then (this is the solution)

Downlaad "https://raw.githubusercontent.com/saltstackme/salt-vagrant/master/salt-installer.sh"

This repo has salt-installer.sh script which installs and configures a salt-master.

* Installs salt-master
* Copies your ssh public and private keys from your home folder to salt-master:/root/.ssh.

## Install vagrant

## Create Folders

## Checkout salt-vagrant

## Create salt-sandbox
