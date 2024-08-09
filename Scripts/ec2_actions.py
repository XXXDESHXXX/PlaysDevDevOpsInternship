import boto3
import paramiko
import os

def create_new_key_pair(key_name):
    ec2 = boto3.client('ec2')
    key_pair = ec2.create_key_pair(KeyName=key_name)
    private_key = key_pair['KeyMaterial']
    
    private_key_path = f'{key_name}.pem'
    with open(private_key_path, 'w') as file:
        file.write(private_key)
    
    os.chmod(private_key_path, 0o400)
    
    public_key_path = f'{key_name}.pub'
    os.system(f'ssh-keygen -y -f {private_key_path} > {public_key_path}')
    
    return private_key_path, public_key_path

def add_public_key_to_instance(instance_ip, username, old_key_path, new_key_path):
    with open(new_key_path, 'r') as file:
        new_public_key = file.read().strip()
    
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh_client.connect(instance_ip, username=username, key_filename=old_key_path)
        command = f'echo "{new_public_key}" > ~/.ssh/authorized_keys'
        stdin, stdout, stderr = ssh_client.exec_command(command)
        errors = stderr.read().decode('utf-8')
        if errors:
            print(f'Error adding public key: {errors}')
        else:
            print('Public key added successfully.')
    finally:
        ssh_client.close()

def create_instance(key_name):
    ec2 = boto3.resource('ec2')

    instance = ec2.create_instances(
        ImageId='ami-0ae8f15ae66fe8cda',
        MinCount=1,
        MaxCount=1,
        InstanceType='t2.micro',
        KeyName=key_name,
        SecurityGroupIds=['sg-001bcf6bd86d1d0b1'],
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'TestPython'
                    }
                ]
            }
        ]
    )[0]

    instance.wait_until_running()
    instance.reload()
    
    return instance

def get_instance_info(instance_id):
    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(instance_id)

    instance_info = {
        'Instance ID': instance.id,
        'Instance State': instance.state['Name'],
        'Instance Type': instance.instance_type,
        'Public IP': instance.public_ip_address,
        'Private IP': instance.private_ip_address,
        'Architecture': instance.architecture,
        'Launch Time': instance.launch_time
    }

    return instance_info

def terminate_instance(instance_id):
    ec2 = boto3.resource('ec2')
    
    instance = ec2.Instance(instance_id)
    
    instance.terminate()
    
    instance.wait_until_terminated()
    
    print(f'Instance {instance_id} has been terminated.')

def main():
    key_name = 'Task_6'
    old_key_path = '/home/kirill/Загрузки/Task_6.pem'
    
    new_key_name = 'python-test-finaly-test-test'
    private_key_path, new_key_path = create_new_key_pair(new_key_name)
    print(f"New key created: {new_key_name}")

    instance = create_instance(key_name)
    
    instance.wait_until_running()
    instance.reload()

    add_public_key_to_instance(instance.public_ip_address, 'ec2-user', old_key_path, new_key_path)
    
    info = get_instance_info(instance.id)
    for key, value in info.items():
        print(f'{key}: {value}')

    instance.wait_until_running()
    instance.reload()

    terminate_instance(instance.id)
    
    print("Process completed. Please verify SSH access with the new key.")

if __name__ == '__main__':
    main()
