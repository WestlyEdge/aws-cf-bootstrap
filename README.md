# aws-cf-bootstrap

## Synopsis

You might fork aws-cf-bootstrap if you are looking to quickly start writing cloud formation stacks against your aws environments. Through the use of a run list, your stacks are consolidated into a singular environment state, the workflow here is very Terraform-ish, you will simply "plan" and then "apply" your stack changes. There are 2 main high level use cases, you may simultaniously take advantage of them both...

1) aws-cf-bootstrap provides a lean convention based framework that you may use to develop your aws infrastructure using aws cloud formation. You would apply a new stack to your dev environment like this...
      - place your template file "foo.yaml" into the [templates](templates) directory
      - add a "foo.yaml" line to the bottom of [run-list.txt](run-list.txt)
      - cd into [environments/dev-us-east-1](environments/dev-us-east-1)
      - if "foo.yaml" requires params, you will provide them @ [environments/dev-us-east-1/params/](environments/dev-us-east-1/params/)foo.txt
      - run [environments/dev-us-east-1/cf-plan.sh](environments/dev-us-east-1/cf-plan.sh) to view the changes you are about to submit
      - run [environments/dev-us-east-1/cf-apply.sh](environments/dev-us-east-1/cf-apply.sh) to apply the changes to your dev environment
      - FYI : scripts exist in the [scripts](scripts) directory, but you'll never run them there, they are symlinked
      
2) aws-cf-bootstrap may be used to quickly provision a clean aws environment with some minimal network infrastructure. 2 stack templates exist with the provided project. Forking this project and running [environments/dev-us-east-1/cf-apply.sh](environments/dev-us-east-1/cf-apply.sh) will create a new VPC with a private subnet and a public subnet containing a nat. You'll modify input param values at [environments/dev-us-east-1/params](environments/dev-us-east-1/params).

## Dependencies

1) aws-cf-bootstrap uses the <a href="http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html">AWS Command Line Interface</a> to send cloud formation commands, so you'll need that.

2) You'll also need <a href="https://direnv.net/">direnv</a>, it's a shell extension that loads different environment variables depending on your path, aws-cf-bootstrap uses direnv to target the correct aws access keys per environment. You'll place a .envrc file in each environment directory (never commit .envrc files to git, a [.gitignore](.gitignore) entry already exists). For more insight, look at [environments/dev-us-east-1/envrc](environments/dev-us-east-1/envrc).

## Contributors

If you would like to add functionality or make this better, by all means, feel free to submit a pull request.
