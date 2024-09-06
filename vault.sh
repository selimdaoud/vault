


export VAULT_OCID=ocid1.vault.oc1.eu-frankfurt-1.entfqncgaacom.abtheljrhw3hfp2zchoqeufu3dluwm65fjsqv2a3l3ptqfz7qjp32qtdfxda
export COMPARTMENT_OCID=ocid1.tenancy.oc1..aaaaaaaahpllo6uema2cycjqdqoi6hy5x4chkmh2vemyno3avdpfupzrkd5a
export KEY_OCID=ocid1.key.oc1.eu-frankfurt-1.entfqncgaacom.abtheljreowqp6uvum5rkz6u5y7v65puytjl4ag6umstwcwxhvj2yokcnkma
export PASSWORD=$(openssl rand -base64 32 | base64) 
export SECRET_NAME="my_secret-demo"
export VAULT_USER_PROFILE="default"              


oci kms management vault list  \
    --profile  $VAULT_USER_PROFILE  \
    -c $COMPARTMENT_OCID \
    --query "data[].{id:id,state:\"lifecycle-state\",name:\"display-name\"}" \
    --auth security_token \
    --all \
    --output table


echo  Create secret
oci vault secret create-base64 \
    --profile $VAULT_USER_PROFILE \
    -c $COMPARTMENT_OCID \
    --secret-name $SECRET_NAME \
    --vault-id $VAULT_OCID \
    --key-id $KEY_OCID \
    --auth security_token \
    --secret-content-content $PASSWORD


echo Get secret ocid
export SECRET_OCID=$(oci vault secret --profile  $VAULT_USER_PROFILE --auth security_token  list -c $COMPARTMENT_OCID --raw-output --query "data[?\"secret-name\" == '$SECRET_NAME'].id | [0]")
echo  List secret versions
oci secrets secret-bundle-version list-versions \
    --profile $VAULT_USER_PROFILE \
    --all \
    --secret-id $SECRET_OCID \
    --query "data[].{\"version-number\":\"version-number\",\"stages\":\"stages\"}" \
    --auth security_token \
    --output table

echo Get secret decoded text
oci secrets secret-bundle get \
    --profile $VAULT_USER_PROFILE \
    --auth security_token \
    --raw-output \
    --secret-id $SECRET_OCID \
    --query "data.\"secret-bundle-content\".content" | base64 -D

