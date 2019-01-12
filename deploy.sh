echo "获取脚本路径"
cur_path=$(cd `dirname $0`; pwd)
echo "进入脚本路径"
cd $cur_path
echo "更新代码"
git pull
echo "打包"
sudo docker build -t myblog:hugo .
echo "停止当前运行的docker"
sudo docker container stop blog
echo "清除docker的无用数据"
echo y | sudo docker system prune 
echo "启动新的docker"
sudo docker run --name blog --rm -p 1313:1313 -d -e HUGO_BASE_URL=http://kentxxq.com/ myblog:hugo