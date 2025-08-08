# 项目介绍

项目原链接：https://github.com/stdeson/wechat-gozero

本人学习了这位大佬的项目作为自己gozero入门，在大佬项目基础上完善了docker-compose.services.yml文件用于部署项目服务

# 项目部署

### 1.新建.env文件用于部署时的依赖注入

MYSQL_PASSWORD：MySQL数据库root密码（对应所有YAML中的${MYSQL_PASSWORD}）需与docker-compose.yml中MySQL的MYSQL_ROOT_PASSWORD保持一致

REDIS_PASSWORD：Redis缓存密码（对应所有YAML中的${REDIS_PASSWORD}）需与docker-compose.yml中Redis的--requirepass参数保持一致

SERVER_IP：服务通信IP/主机名（对应所有YAML中的${SERVER_IP}）容器间通信：使用中间件服务名（如mysql、redis、kafka0） 外部访问：替换为部署服务器的实际IP（如192.168.1.100）

JWT_SECRET：JWT认证密钥（对应所有YAML中的${JWT_SECRET}）用于API和RPC服务的Token签名与验证，生产环境需使用高强度密钥

### 2.启动依赖服务

> docker-compose -f docker-compose.yml up -d

tag : docker-compose文件启动MySQL没有自动创建表，可以根据项目中的sql文件手动创建

tag : log_pilot服务似乎与最新版本docker不兼容，可以试试其他的日志收集工具

### 3.启动项目服务

> docker-compose -f docker-compose.services.yml up -d

### 4.kafka配置

访问 localhost:8080 进入kafka管理页面，账号密码为admin

添加集群kafkay运行端口为9093/9094

创建topic名称为msg_chat，分区5，副本2

# 接下来的计划

### 2025.8.6

problem : 创建新用户logic中，将新用户加上系统用户好友后发送初始消息目前是重复编写了msg模块的逻辑

target : 更改为分布式事务调用msg_rpc逻辑