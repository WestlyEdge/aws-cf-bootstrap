# aws-cf-bootstrap

## Synopsis

You might fork aws-cf-bootstrap if you are looking to quickly start writing cloud formation stacks against your aws environments. There are 2 main use cases, you may simultaniously take advantage of them both...

1) aws-cf-bootstrap provides a lean convention based framework that you may use to develop your aws infrastructure using aws cloud formation. You would apply a new stack to your dev environment like this...
  - write your new template file "foo.yaml" and place into the templates directory
  - add a "foo.yaml" line to run-list.txt
  - cd into environments/dev
  - run plan.sh to create a changeset and view the changes you are about to submit
  - run apply.sh to apply the changes to your dev environment

## Contributors

Let people know how they can dive into the project, include important links to things like issue trackers, irc, twitter accounts if applicable.
