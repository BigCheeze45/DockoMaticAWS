# DockoMatic on AWS
DockoMatic is a GUI application taht is intended to ease and automate the creation and management of AutoDock jobs for high throughtput screning of ligand/receptor interactions.

This project uses [Terraform](https://www.terraform.io/) to create an [Amazon Web Services (AWS)](https://aws.amazon.com/) infrastructure to run [DockoMatic](https://goo.gl/n2tgKo)
in the cloud.

**NOTE:** Development is on-going for this project and things might break sometime :smile:

## Requirments
To get this project up and running you will need the following:
  * [AWS account](https://aws.amazon.com/)
    * With an AWS account you can then get a [access and secret key](https://goo.gl/b9rHov). It is recommend NOT to use the root account (i.e. owner account) but instead an IAM user.
  * [Terraform](https://www.terraform.io) (0.10.x and up) and [Terraform AWS provider](https://github.com/terraform-providers/terraform-provider-aws)
  * [MODELLER license key](https://goo.gl/ufNr7Z)

## Setup
First in the root of the project run `terraform init`. Next, while still in the root of the project create a new file named `terraform.tfvars` with the
following *__required__* keys and their corresponding values:

  ```terraform
  access_key = "AWS user access key"
  secret_key = "AWS user secret key"
  region = "AWS region"
  instance_type = "AWS instance type"
  modeller_license_key = "MODELLER license key"
  ```
  A complete list of supported keys and their default values can be found
  [below](#paramters-defaults).

  In `aws_config.tf` find and update the following to point to the directory
  containing your test file to be uploaded to the instance. Do *not* include a
  trailing slash (i.e. `path/to/directory/`). Note that the test directory will
  be placed in the home directory on the remote instance with the same name.

  ```terraform
  # Upload directory containing your test files
  provisioner "file" {
    # # # CHANGE ME # # #
    source      = "path/to/test/directory"
    destination = "/home/fedora"
  }
  ```

## Validate, Plan, And Execute
Once you've configured the `terraform.tfvars` and `aws_config.tf` files run
`terraform validate` to check the syntax. Resolve any issue that is found.

You can run `terraform plan` to create an execution plan. This will show you all
the resources that will be created. Resolve any missing parameters.

Once all issues have been resolved run `terraform apply` to start the process of
creating and powering on all the AWS resources. The instances will be provisioned
with DockoMatic and your test file.

If there are no issues the script will continue to completion and display the
public IP of all the instances. The public IP can be use to connect to the instances.

## Connecting to the instance (VM)
In order to connect to your instance you will need both an
[Amazon EC2 Key Pair](https://goo.gl/dS8Dty) and the public IP of the instance.
The default user-name on the instance is `fedora`. So, with all the required
pieces you can connect to your instance as follow:
`ssh -i <path/to/key.pem> -X fedora@<public-IP>`

You can start DockoMatic on the instance by typing `dockomatic` into the terminal. The program will load and warn some modules are missing. Click to disable the modules and continue.

## Downloading Your Test Results
When your jobs are finished running the files will need to be uploaded to S3 for you to download. That can be done using `s3-upload`:

```
s3-upload <s3-bucket-name> <source> [dryrun]
Options:
 s3-bucket-name: The name of the S3 bucket to upload the content of source into
 source: The source file or directroy to upload to the specified S3 bucket. Files will be uploaded directly into the bucket and folders will be created in the bucket for sub-directories within source
 dryrun: Displays the operations that would be performed using the specified command without actually running them
```
You can run `aws s3 ls` to list all buckets you have access to. You can download your files through the AWS web console once the file upload is complete.

## Destroying Resources (Use with care)
When you are ready to tear down everything simply run `terraform destroy` on your local machine. This terminate any running instance as well as destroy all Terrafrom created resources. **There is NO UNDO!**

__**NOTE:**__ The Terraform created S3 bucket will NOT be destroy if there are files in it. Terraform will throw an error because of this and that is OK. You can empty the bucket manuly through the web console and re-run `terraform destroy` or delete it all together from the web console. In either case make sure to get your test results.

## Parameter Defaults
The following are all available parameters with their default values. If you
intend *not* to use the default make sure to specified the value in your
`terraform.tfvars` file.

|Parameter           | Description                                          | Default|
|-------------       |:-------------:                                       |  -----:|
|access_key          |[AWS IAM user access key](https://goo.gl/b9rHov)      | `N/A`  |
|secret_key          |[AWS IAM user secret key](https://goo.gl/b9rHov)      | `N/A`  |
|modeller_license_key|[MODELLER license key](https://goo.gl/ufNr7Z)         | `N/A`             |
|aws_key_pair        |Public key file use to connect to instance            |`~/.ssh/id_rsa.pub`|
|s3_bucket_name      |S3 bucket name. Test results are stored in this bucket|`dockomaticresults`|
|region              |Supported AWS region to creat all resources in        |`us-east-1`|
|amis                |Supported AMI IDs                                     |see table below|
|instance_type       |[AWS instance types](https://goo.gl/tLFwSp)           |`t2.micro`|
|instance_count      |Number of instance (minus master node) to create      |`0`       |

AWS Amazon Machine Image (AMI) are region based. Meaning each of the supported
region has its own image and using the wrong one will result in an error. This
project has been configured to automatically use the correct image based on the
specified region. Below are supported regions with their corresponding location
and AMI ID.

| Region        | Location        | AMI ID|
| ------------- |:-------------:  | -----:|
| us-west-2     | Oregon          | `ami-2c1c0f55`|
| us-east-1     | North Virginia  | `ami-bb6065ad`|
| us-west-1     | North California| `ami-31113e51`|
| ap-northeast-1| Tokyo           | `ami-6e7b6409`|
| ap-southeast-1| Singapore       | `ami-29850f4a`|
| eu-central-1  | Frankfurt       | `ami-5364c43c`|
| eu-west-1     | Ireland         | `ami-aac928d3`|
| sa-east-1     | Sao Paulo       | `ami-6675000a`|
