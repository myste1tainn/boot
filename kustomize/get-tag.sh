# =================
# Command >>> sh kustomize-get-tag.sh {input_file.csv} {env} {kustomize branch}
# =================
# Example
# sh kustomize-get-tag.sh fin_input_update_pod.csv pfm release

# =================
# Input file format
# =================
# ms_name,tag


get_tag () {
    # 1=env 2=tag
    if [ -f "overlays/$1/kustomization.yml" ]
    then
        tag=$(yq ".images[].newTag" "overlays/$1/kustomization.yml")
    else
        tag=$(yq ".images[].newTag" "overlays/$1/kustomization.yaml")
    fi
}

clone_and_checkout_kustomize () {
    #1=ms 2=branch
    if [ ! -d $1 ] 
    then 
    git clone "ssh://git@gitdev.devops.krungthai.com:2222/cicd/kustomize/next/$1.git"
    fi
    cd $1
    git fetch -ap
    git checkout $2
    git pull
    cd ..
}

################ Execute ################ 

echo "[Info] START GET TAG!!"

input_file=$1
env=$2
branch=$3
output_file="result/kustomize_tag_$(date "+%y%m%d%H%M%S").csv"

echo "[Info] Output file is $output_file"

#loop file in csv
while IFS="" read -r p || [ -n "$p" ]
do
    ms=$(echo $p | cut -d ',' -f1)
    tag1=$(echo $p | cut -d ',' -f2)

    cd repository
    clone_and_checkout_kustomize $ms $branch
    
    # update tag
    cd $ms
    get_tag $env $tag
    # echo $tag
    cd ../..

    if [[ "$tag1" == "$tag" ]]
    then
        eq='Y'
    else
        eq='N'
    fi
    echo "$ms,$tag1,$tag,$eq" >> $output_file
    echo "[Info] $ms done."
done < $input_file

echo "[Info] DONE Getting Tag!"
