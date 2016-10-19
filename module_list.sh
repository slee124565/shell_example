
git_app_list="git@git-cn.xxx.co:devin/vds_es_server.git
git@git-cn.xxx.co:devin/vds_vcms.git
git@git-cn.xxx.co:devin/vds_api.git
git@git-cn.xxx.co:morton/vds_hrs.git"

git_vhost_list="git@git-cn.xxx.co:bing/vhost.git -b master
git@git-cn.xxx.co:lee/orbit-si.git -b master"

git_proj_list="${git_app_list}"
${git_vhost_list}

git_app_list="http://git-cn.xxx.co/devin/vds_es_server.git
http://git-cn.xxx.co/devin/vds_vcms.git
http://git-cn.xxx.co/devin/vds_api.git
http://git-cn.xxx.co/morton/vds_hrs.git"

git_vhost_list="http://git-cn.xxx.co/bing/vhost.git -b master
http://git-cn.xxx.co/lee/orbit-si.git -b master"

git_proj_list="${git_app_list}"
${git_vhost_list}
