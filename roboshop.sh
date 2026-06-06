script_name=$(basename $0 .sh)
script_dir=$(realpath $(dirname $0))
logs_dir="${script_dir}/logs"
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="${logs_dir}/${script_name}_${timestamp}.log"
mkdir -p $logs_dir

export AWS_PROFILE="deva"
export ANSIBLE_FORCE_COLOR=True
export PYTHONUNBUFFERED=1

exec > >(tee -a $log_file) 2>&1

#color variables
R="\e[31m"
Y="\e[32m"
G="\e[33m"
B="\e[34m"
N="\e[0m"

#timing
start_time=$(date +%s)
echo -e "Script run started @ $B ... $(date) ... $N"

function caculate_total_time(){
    end_time=$(date +%s)
    time_taken=$(( $end_time - $start_time ))
    seconds=$(( time_taken % 60 ))
    minutes=$(( time_taken/60 % 60 ))
    hours=$(( time_taken/60/60 ))

    echo -e "Script run ended @ $B ... $(date) ... $N"
    echo "===========Total Time Taken================"
    echo -e "---------($B ${hours} hrs, ${minutes} min, ${seconds} sec $N)-----------"
    echo "==========================================="
}


inventory_file="${script_dir}/inventory.ini"

instances=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "frontend")

json_payload=$(jq -n \
    --argjson instances "$(printf '%s\n' "${instances[@]}" | jq -R . | jq -s .)" \
    '{
        instance_action: "create",
        instances: $instances
    }')

ansible-playbook "${script_dir}/01_roboshop.yaml" \
    -i $inventory_file \
    -e "$json_payload"


function validate_playbook(){
    if [[ $? -ne 0 ]]; then
        echo -e "$R Something is up, There is an error in running the playbook for the instance ... $1 ... $N"
        caculate_total_time
        exit 1;
    else
        echo -e "$G completed the playbook for the instance ... $instance .... $N"
    fi
}

validate_playbook "main-playbook-creating instances" 

for instance in "${instances[@]}"; do
    echo -e "$B running the playbook for the instance ... $instance .... $N"
    ansible-playbook "${script_dir}/${instance}.yaml" -i "$inventory_file"
    validate_playbook $instance
    echo "==========================================================="
done

caculate_total_time