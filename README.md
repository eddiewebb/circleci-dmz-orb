# circleci-dmz-orb

Allows CircleCI builds to access private network services over a intermediate jump host using SSH port forwarding.


![Image showing traffic flow from CircleCI, through Jump Host to target server on private network](/assets/bastion.png)

**Note**: port 3306 represents the local port, in this example for a DB connection, but can be any available port.

## Examples

```
version: 2.1

orbs:
  dmz: eddiewebb/dmz@dev:local

workflows:
  test_all:
    jobs:
      - build
      - build_key_path
      - build_key_value
      - build_key_variable

jobs:
  build: # this job uses ssh-keyscan to dynamically trust public key of bastion host
    docker:
      - image: circleci/node:10
    steps:
      - checkout
      - dmz/open_tunnel:
          local_port: "9001"
          target_host: "104.154.89.105"
          target_port: "80"
          bastion_user: ubuntu
          bastion_host: ec2-18-191-19-150.us-east-2.compute.amazonaws.com 
      # and simply confirm that accessing local port resolves the target (in this case an HTTP server)
      - run: curl localhost:9001
  
  build_key_path: #this job uses a *public* key file within the repo to be explicitly trusted
    docker:
      - image: circleci/node:10
    steps:
      - checkout
      - dmz/open_tunnel:
          local_port: "9001"
          target_host: "104.154.89.105"
          target_port: "80"
          bastion_user: ubuntu
          bastion_host: ec2-18-191-19-150.us-east-2.compute.amazonaws.com
          bastion_public_key: bastion.pub
      # and simply confirm that accessing local port resolves the target (in this case an HTTP server)
      - run: curl localhost:9001
  
  build_key_value: # this job uses a public key string value to trust bastion explicitly
    docker:
      - image: circleci/node:10
    steps:
      - checkout
      - dmz/open_tunnel:
          local_port: "9001"
          target_host: "104.154.89.105"
          target_port: "80"
          bastion_user: ubuntu
          bastion_host: ec2-18-191-19-150.us-east-2.compute.amazonaws.com
          bastion_public_key: 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEQonlo27Q6jHMBHm7FczYsVbSDMMejUCZmSTcloE2DrDNfL/fzbzNlP5Xk8MxqRfjrPEsrlvRlyNYSxDLVA+0g='
      # and simply confirm that accessing local port resolves the target (in this case an HTTP server)
      - run: curl localhost:9001
  
  build_key_variable: # this job uses a public key string value to trust bastion explicitly
    docker:
      - image: circleci/node:10
    steps:
      - checkout
      - dmz/open_tunnel:
          local_port: "9001"
          target_host: "104.154.89.105"
          target_port: "80"
          bastion_user: ubuntu
          bastion_host: ec2-18-191-19-150.us-east-2.compute.amazonaws.com
          bastion_public_key: ${BASTION_PUBLIC_KEY}
      # and simply confirm that accessing local port resolves the target (in this case an HTTP server)
      - run: curl localhost:9001
```

