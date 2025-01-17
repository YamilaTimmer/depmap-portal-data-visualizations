# Hosting plan Shiny app

## Prerequisites
It's important to first have R and the Shiny R package installed, I already have both installed but below I included how to install them:

**Installing R**
```bash
sudo apt-get install r-base
```

Installing the Shiny R package can be done in two ways:

**Installing Shiny R package (bash)**
```bash
sudo su - -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
```

**Installing Shiny R package (R)**
```r
install.packages("shiny")

```
## Installing Shiny Server
First, `gdebi` will have to be installed. `gdebi` makes installing Shiny Server easier, because it will also install all of its dependencies. Keep in mind that `sudo` rights are needed in order to continue.

**Installing `gdebi`-package**
```bash
sudo apt-get install gdebi-core
```

**Downloading newest version of Shiny Server**
```bash
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb
```

**Using gdebi to install Shiny Server + dependencies**
```bash
sudo gdebi shiny-server-1.5.22.1017-amd64.deb
```

After installing the Shiny Server, a systemd service (`shiny-server`) will be installed, which causes the Shiny Server to automatically start when the machine boots up and stop when the machine shuts down. Right after installing the server will automatically start running. There has also been made a default configuration file for the server (`shiny-server.conf`). The contents of the config file can be seen below and contain specifications on elements such as the port that will be listened to for HTTP requests. It also specifies locations (directories) for the application root (site_dir) and for logs (log_dir). 

### default config
```
# Define the user we should use when spawning R Shiny processes
run_as shiny;

# Define a top-level server which will listen on a port
server {
  # Instruct this server to listen on port 3838
  listen 3838;

  # Define the location available at the base URL
  location / {
    #### PRO ONLY ####
    # Only up tp 20 connections per Shiny process and at most 3 Shiny processes
    # per application. Proactively spawn a new process when our processes reach 
    # 90% capacity.
    utilization_scheduler 20 .9 3;
    #### END PRO ONLY ####

    # Run this location in 'site_dir' mode, which hosts the entire directory
    # tree at '/srv/shiny-server'
    site_dir /srv/shiny-server;
    
    # Define where we should put the log files for this location
    log_dir /var/log/shiny-server;
    
    # Should we list the contents of a (non-Shiny-App) directory when the user 
    # visits the corresponding URL?
    directory_index on;
  }
}

# Setup a flat-file authentication system. {.pro}
auth_passwd_file /etc/shiny-server/passwd;

# Define a default admin interface to be run on port 4151. {.pro}
admin 4151 {
  # Only permit the user named `admin` to access the admin interface.
  required_user admin;
}
```
### Port settings
The standard port that the Shiny Server listens to is port 3838. 

### Server locations
The location given for `site_dir`, is the part that will be hosted. So for my project I would have to move at least the `app`-directory (which contains functions.R, server.R, ui.R) into `/srv/shiny-server`. Other than that I can also add static files, such as the Exploratory Data Analysis (EDA), which can then be viewed as well (see [directory_index](hosting_plan.md#directory_index)). This can be done with:

```bash
sudo cp -r /path/to/repo /srv/shiny-server/
```

The location given for `log_dir`, is where log files will be saved. These include things such as error logs and access logs (details about requests that have been made to the server).

### Setting possible number of users/processes/connections
With `utilization_scheduler 20 .9 3;` it's specified how many connections can be made to the server per process (20) and how many processes there can be per application (3). A new process starts when the current process is at 90% capacity (.9), and in total 60 concurrent users can use the application (3 processes that can all connect 20 users). These settings can only be changed in Shiny Server Pro.

- **maxRequestsPerProc**: number of connections that is supported by a single R process, if the number is surpassed, a 503 error will be returned to the user.
- **loadFactor**: percentage (0-1) of process capacity, when this is reached a new connection will be spawned (until maxProc is reached).
- **maxProc**: maximum number of processes that can exist concurrently within the application.

The free version of Shiny Server does not let you define the amount of users, which could be a problem, because this means a large amount of users/connections can be established at the same time. Potentially slowing the application down. This also means that only one process can be active at all times, meaning all connections are made within the same process. All users are connected to the same R session and R is a single-threaded language, so only one task can be executed at a time. Loading times in my app are caused by making any changes to the filtered data. Generating the different types of plots then takes place fairly quickly without much time. 

Having 10 concurrent users, without long loading times, seems very possible to me, as the users are not expected to constantly change the filter parameters, but spend more time looking at the plots and changing settings there. However, having e.g. 100 users will surely make the loading times longer, as there will likely be people changing the filter parameters at all times. Hence I think this app would work optimally with a small amount of users. If I would want the app to remain working optimally, with a larger amount of users, I would need multiple processes to run in the same instance (which can be done with Shiny Server Pro) and set `maxRequestsPerProc` to 10 connections per process.

### directory_index
`directory_index` can be set with either `on` or `off`. If it is set to `on`, this means that if a user navigates to a URL that corresponds to a directory in the server (which is **not** the application itself), the user is able to see the contents of the directory, in a 'file viewer'. If directory_index is switched `off`, the user will get a 403 error code, which will not allow them to view the contents of the directory, which is useful in case of sensitive data/files. However, in this case, I am not working with sensitive data (the data used is accessible online), so I will keep `directory_index on;` unchanged.

### Version control
Over time, bugs will be fixed and new features might be added. This results in new versions of the app and/or contents within the repo. These would have to manually be copied to the server folder every time. This can be automised using Git hooks, specifically the `post-receive` hooks, seeing as I want the server to be updated **after** the repo has been updated (see img below displaying the types of git hooks). Git hooks are in the `.git/hooks` folder and can manually be changed, so for this to work, the `post-receive hook` in the .git folder would need to have some instructions for git to copy the updated app to the server directory, after every push.

![](..\media\git_hooks.PNG)

## Using a proxy
In order to make the app available as HTTP (80) or HTTPS (443), a reverse-proxy is needed. The reason being that I don't have the rights to bind a process to any port below 1024 (*"well-known ports"*). The reverse-proxy will then forward any request made from the domain to the to the local server. Either `nginx` or `apache` would work for this, however I am choosing for `apache`, seeing as apache is more suited for more complex/reactive apps. 

### Installing apache

```bash
sudo apt-get install apache2
sudo apt-get install libapache2-mod-proxy-html
sudo apt-get install libxml2-dev
```

### Updating apache config files
```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
```

### Proxy configuration
After installing and updating apache, there needs to be a config file that tells the proxy how to do the websocket handling, HTTP handling and how to handle proxy requests. Below is an example of a proxy config file for apache that does all the aforementioned. 

The number behind `VirtualHost` (80), tells the proxy what port to listen to. In this case HTTP was used, but for HTTPS the number can be changed to 443 (however additional SSL configuration will have to be done).

```
<VirtualHost *:80>

  <Proxy *>
    Allow from localhost
  </Proxy>
 
 RewriteEngine on
 RewriteCond %{HTTP:Upgrade} =websocket
 RewriteRule /(.*) ws://localhost:3838/$1 [P,L]
 RewriteCond %{HTTP:Upgrade} !=websocket
 RewriteRule /(.*) http://localhost:3838/$1 [P,L]
 ProxyPass / http://localhost:3838/
 ProxyPassReverse / http://localhost:3838/
 ProxyRequests Off

</VirtualHost>\
```

# Sources
- Posit. (n.d.). Shiny Server Professional v1.5.22 Administrator’s Guide. https://docs.posit.co/shiny-server/
- Posit. (2024, 26 april). Shiny Server v1.5.22.1017. https://posit.co/download/shiny-server/
- Pylvainen, I. (2024, 2 juni). Running Shiny Server with a Proxy. https://support.posit.co/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy
