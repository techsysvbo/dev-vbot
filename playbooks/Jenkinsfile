pipeline{
    agent any
    environment{
        TF_IN_AUTOMATION= 'true'
        TF_CLI_CONFIG_FILE = credentials('tf-creds')
        AWS_SHARED_CREDENTIALS_FILE='/home/ubuntu/.aws/credentials'
    }
    stages {
        stage('init') {
            steps {
            sh 'ls'
            sh 'cat $BRANCH_NAME.tfvars'
            sh 'export TF_IN_AUTOMATION=true'  //delete this export line and others
            sh 'terraform init -no-color'
        }
        
    }
    stage('Plan'){
        steps {
            sh 'export TF_IN_AUTOMATION=true'
            sh 'terraform plan -no-color -var-file="$BRANCH_NAME.tfvars"'
         }
      }

    stage('Validate Apply'){
        when{
            beforeInput true 
            branch "dev"
        }
        input {
            message "Do you want to apply this plan?"
            ok "Apply this plan."
        }
        steps{
            echo 'Apply Accepted'  //Stps must be added for this to work
        }
    }

    stage('Apply'){
        steps{
            sh 'export TF_IN_AUTOMATION=true'
            sh 'terraform apply -no-color -auto-approve -var-file="$BRANCH_NAME.tfvars"'
        }
    }

    stage('Inventory') {
        steps {
            sh '''printf \\
            "\\n$(terraform output -json instance_ips | jq -r \'.[]\')" \\
             >> aws_hosts'''
            }
        }

    stage('EC2 Wait') {
        steps {
            sh '''aws ec2 wait instance-status-ok \\
                      --instance-ids $(terraform output -json instance_ids | jq -r \'.[]\') \\
                      --region us-west-1'''
        }
    }

    stage('Validate Ansible'){
        when{
            beforeInput true 
            branch "dev"
        }
        input {
            message "Do you want to run Ansible?"
            ok "Apply Ansible."
        }
        steps{
            echo 'Ansible Approved'  //Stps must be added for this to work
        }
    }

    stage('Ansible'){
        steps{
            ansiblePlaybook(credentialsId: 'ec2-ssh-key', inventory: 'aws_hosts', playbook: 'playbooks/grafana.yml')
        }
    }
 
    stage('Test Grafana and Prometheus') {
        steps {
            ansiblePlaybook(credentialsId: 'ec2-ssh-key', inventory: 'aws_hosts', playbook: 'playbooks/node-test.yml')
        }
    }

    stage('Validate Destroy'){
        input {
            message "Do you want to destroy all resources?"
            ok "Destroy!"
        }
        steps{
            echo 'Destroy Accepted'  //Stps must be added for this to work
        }
    }

    stage('Destroy'){
        steps{
            sh 'export TF_IN_AUTOMATION=true'
            sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"' // Specifies the branch using jenkins var. 
        }
    }
 }
 post {
    success {
        echo 'Success'
    }
    failure {
        sh 'terraform destroy -auto-approve -no-color'
    }
    aborted {
        sh 'terraform destroy  -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
    }
 }
} 

// cp below and use Jenkins syntax to ensure jenkinsfile runs. 
// terraform.exe show -json|jq -r '.values'.'root_module'.resources[] | select(.type == "aws_instance").values.id'
// aws ec2 wait instance-status-ok  \
// --instance-ids $(terraform.exe show -json|jq -r '.values'.'root_module'.resources[] | select(.type == "aws_instance").values.id)\
// --region us-east-1

// Also add this to Jenkinsfile after using Jenkins syntax
// printf \
// "\n$(terraform output -json instance_ips | jq -r '.[]')" \
// aws_hosts

// ENSURE us add Ec2 Wait also. Instead of i.public_ids use i.id. subst id for public_ids in 2 or 3 places total