script_name=$(basename $0 .sh)
script_dir=$(realpath $(dirname $0))

export AWS_PROFILE=deva

ansible-playbook "${script_dir}/01_roboshop.yaml" -i "${script_dir}/../inventory.ini" -e \
                                                        "$(
                                                            jq -n \
                                                                '{
                                                                    instance_action: "create",  
                                                                    instances: ["mongodb", "frontend", "catalogue"]                                                           
                                                                }'
                                                        )"