#bin/sh

cd infrastructure/cdk
echo "The following stacks will be deleted:"
cdk list
cdk destroy --all --force
aws ecr delete-repository \
    --repository-name unicorn-store-repo \
    --force
cd -