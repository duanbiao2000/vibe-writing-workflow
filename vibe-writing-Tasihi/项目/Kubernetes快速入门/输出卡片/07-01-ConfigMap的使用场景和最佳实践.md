## ConfigMap的使用场景和最佳实践

你有没有遇到过这样的困扰：应用程序的配置在不同的环境（开发、测试、生产）中需要不同的值，但你又不想为每个环境维护不同的代码或镜像？

这就是ConfigMap要解决的问题。它可以让你将配置信息与应用程序代码分离，实现一次构建，到处运行。

### 什么是ConfigMap？

ConfigMap是一种Kubernetes资源对象，用于存储非机密性的键值对配置数据。它可以被Pod使用，用来设置环境变量、命令行参数，或者在存储卷中创建配置文件。

### ConfigMap的核心使用场景

#### 1. 环境差异化配置

不同环境需要不同的配置值，比如数据库连接字符串：

```yaml
# 开发环境
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-dev
data:
  database.url: "dev-db.mycompany.com:5432"
  log.level: "debug"

---
# 生产环境
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-prod
data:
  database.url: "prod-db.mycompany.com:5432"
  log.level: "warn"
```

#### 2. 应用配置文件管理

将配置文件内容存储在ConfigMap中：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {
      worker_connections 1024;
    }
    http {
      server {
        listen 80;
        location / {
          root /usr/share/nginx/html;
          index index.html;
        }
      }
    }
```

#### 3. 命令行参数传递

为容器设置启动参数：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-options
data:
  max-threads: "10"
  timeout: "30s"
```

### ConfigMap的四种使用方式

#### 1. 环境变量注入

最简单的使用方式，将ConfigMap中的键值对作为环境变量注入到容器中：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  containers:
  - name: demo-container
    image: nginx
    env:
    # 引用单个键值对
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.url
    # 引用所有键值对
    - name: CONFIG_VARS
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log.level
```

#### 2. 命令行参数传递

将ConfigMap中的值作为命令行参数传递给容器：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  containers:
  - name: demo-container
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
    - echo "Database URL: $(DATABASE_URL)";
      echo "Log Level: $(LOG_LEVEL)";
      sleep 3600
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log.level
```

#### 3. 存储卷挂载

将ConfigMap作为文件挂载到容器中：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  containers:
  - name: demo-container
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/app/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

#### 4. 在PodSpec中指定默认环境变量

为整个Pod设置默认的环境变量：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo-pod
spec:
  containers:
  - name: demo-container-1
    image: nginx
  - name: demo-container-2
    image: busybox
  envFrom:
  - configMapRef:
      name: app-config
```

### ConfigMap最佳实践

#### 1. 合理组织配置项

将相关的配置项组织在一起：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: database-config
data:
  # 数据库连接相关
  db.host: "mysql-service"
  db.port: "3306"
  db.name: "myapp"
  
  # 连接池相关
  db.pool.max-size: "20"
  db.pool.min-size: "5"
  db.pool.timeout: "30s"
```

#### 2. 使用有意义的命名

```yaml
# 好的命名方式
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
data:
  redis.address: "redis-master:6379"
  mysql.dsn: "user:password@tcp(db-service:3306)/users"

---
# 不推荐的命名方式
apiVersion: v1
kind: ConfigMap
metadata:
  name: config
data:
  addr: "redis-master:6379"
  dsn: "user:password@tcp(db-service:3306)/users"
```

#### 3. 避免存储敏感信息

ConfigMap不适合存储密码、API密钥等敏感信息，应该使用Secret：

```yaml
# 错误做法：在ConfigMap中存储密码
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  username: "admin"
  password: "supersecretpassword"  # 不安全！

---
# 正确做法：使用Secret存储敏感信息
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64编码的"admin"
  password: c3VwZXJzZWNyZXRwYXNzd29yZA==  # base64编码的"supersecretpassword"
```

#### 4. 使用标签和注解

为ConfigMap添加标签和注解，便于管理和追踪：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    app: myapp
    version: v1.0
    environment: production
  annotations:
    description: "应用程序配置"
    contact: "dev-team@company.com"
    last-updated: "2025-12-11"
data:
  log.level: "info"
  api.timeout: "30s"
```

### ConfigMap更新和热重载

ConfigMap的一个重要特性是支持更新，但需要注意的是，默认情况下，挂载为存储卷的ConfigMap不会自动更新容器中的文件。

#### 实现配置热更新的方法

1. **使用环境变量**：环境变量会在Pod重启后更新
2. **使用存储卷挂载配合应用重载机制**：应用需要监听配置文件变化并重新加载
3. **使用initContainer**：在应用启动前重新挂载最新的配置

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-hot-reload
spec:
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/app/config
    # 应用需要支持配置重载信号
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "kill -HUP 1"]
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### 小结

ConfigMap是Kubernetes中管理应用配置的重要工具，它帮助我们实现了配置与代码的分离，提高了应用的灵活性和可维护性。通过合理使用ConfigMap，我们可以：

1. 简化不同环境的配置管理
2. 提高应用的可移植性
3. 实现配置的动态更新
4. 保持代码的整洁和一致性

记住，ConfigMap适用于非敏感的配置数据，敏感信息应该使用Secret来管理。