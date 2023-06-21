access_log /var/log/nginx/new.melrio.com.access.log;

server {
        listen 80;
        server_name new.melrio.com ;
        charset utf-8;

        location /static/ {
            alias /var/www/backend/melrio.com/static/;
        }

        location /media/ {
            alias /var/www/backend/melrio.com/media/;
        }

        location / {
            client_max_body_size 30000M;
            client_body_buffer_size 200000K;
            proxy_redirect off;
            proxy_set_header  Host melrio.com;
            proxy_set_header  X-Real-IP $remote_addr;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header  X-Forwarded-Host $server_name;

            include /etc/nginx/uwsgi_params;
            uwsgi_pass unix:/var/www/backend/melrio.com/melrio.sock;
        }
}
