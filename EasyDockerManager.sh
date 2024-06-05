#!/bin/bash
MAINARG="$1"
# -------------------------------------------------
if [ "$MAINARG" == "q" ]; then
    # Variables for quick use
    QUICKNAME="$2"
    QUICKINTERACTIVE="$3"
    QUICKRESTART="$4"
    
    # Check if any containers with the specified name exist
    existing_container=$(sudo docker ps -a --filter "name=$QUICKNAME" --format "{{.ID}}")

    if [ -n "$existing_container" ]; then
        # Find the latest stopped container with the specified name
        latest_stopped_container=$(sudo docker ps -a --filter "name=$QUICKNAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)
        if [ -n "$latest_stopped_container" ]; then
            # Restart the latest stopped container
            echo "Starting the latest stopped container: $latest_stopped_container"
            if [ "$QUICKINTERACTIVE" == "1" ]; then
                sudo docker start -i "$latest_stopped_container"
                exit 0
            else
                sudo docker start "$latest_stopped_container"
                exit 0
            fi
        else
            # If no stopped containers, choose to restart or no
            running_container=$(sudo docker ps --filter "name=$QUICKNAME" --format "{{.ID}}" | head -n 1)
            if [ "$QUICKRESTART" == "1" ]; then
                echo "Container is being restarted: $running_container"
                if [ "$QUICKINTERACTIVE" == "1" ]; then
                    sudo docker restart "$running_container"; sudo docker exec -it "$running_container" /bin/bash
                    exit 0
                else
                    sudo docker restart "$running_container"
                    echo "Container has been restarted: $running_container"
                    exit 0
                fi
            else 
                if [ "$QUICKINTERACTIVE" == "1" ]; then
                    echo "Entering container: $running_container"
                    sudo docker exec -it "$running_container" /bin/bash
                    exit 0
                else
                    echo "Container is already running: $running_container"
                    exit 0
                fi
            fi
        fi
    else
        # If no container exists with the specified name, create a new one
        image_id=$(sudo docker images --quiet "$QUICKNAME" | head -n 1)
        if [ -n "$image_id" ]; then
            echo "No container found with name $QUICKNAME. Creating a new container."
            if [ "$QUICKINTERACTIVE" == "1" ]; then
                sudo docker run -it --name "$QUICKNAME" "$QUICKNAME"
                exit 0
            else 
                sudo docker run --name "$QUICKNAME" "$QUICKNAME"
                exit 0
            fi
        else 
            echo "No container found with name $QUICKNAME. Cannot create a new container because the image doesn't exist."
            exit 1
        fi
    fi
# -------------------------------------------------
elif [ "$MAINARG" == "containers" ]; then
    # Echo all containers
    sudo docker ps -a --format "{{.Names}} {{.Status}}" | while read -r container status; do 
        if [[ "$status" == *"Up"* ]]; then 
            printf "%s - Active\n" "$container"
        else 
            printf "%s - Inactive\n" "$container"
        fi
    done
# -------------------------------------------------
elif [ "$MAINARG" == "images" ]; then
    # Echo all images
    echo $(sudo docker images --format "{{.Repository}}")
# -------------------------------------------------
elif [ "$MAINARG" == "rm" ]; then
    NAME="$2"
    latest_container=$(sudo docker ps -a --filter "name=$NAME" --format "{{.ID}}" | head -n 1)
    if [ -n "$latest_container" ]; then
        latest_stopped_container=$(sudo docker ps -a --filter "name=$NAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)
        if [ -n "$latest_stopped_container" ]; then
            sudo docker rm "$latest_stopped_container"
            echo "Container has been removed: $latest_container"
            exit 0
        else
            sudo docker stop "$latest_container"; sudo docker rm "$latest_container"
            echo "Container has been stopped and removed: $latest_container"
            exit 0
        fi
    else 
        echo "Container $NAME doesn't exist."
        exit 1
    fi
elif [ "$MAINARG" == "rmi" ]; then
    NAME="$2"
    image_id=$(sudo docker images --quiet "$NAME" | head -n 1)
    if [ -n "$image_id" ]; then
        echo "Image has been removed: $NAME"
        exit 0
    else
        echo "Image doesn't exist: $NAME"
        exit 1
    fi
elif [ "$MAINARG" == "stop" ]; then
    NAME="$2"
    latest_container=$(sudo docker ps -a --filter "name=$NAME" --format "{{.ID}}" | head -n 1)
    if [ -n "$latest_container" ]; then
        latest_stopped_container=$(sudo docker ps -a --filter "name=$NAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)
        if [ -n "$latest_stopped_container" ]; then
            sudo docker stop "$latest_container";
            echo "Container has been stopped: $latest_container"
            exit 0
        else
            echo "Container $latest_container is already stopped."
            exit 0
        fi
    else 
        echo "Container $NAME doesn't exist."
        exit 1
    fi
elif [ "$MAINARG" == "help" ]; then
    echo "
Echo all container names:
    dockerStarter containers
Echo all image names:
    dockerStarter images

Remove container arguments:
    arg 1 - 'rm'
    arg 2 - name[req]
Remove image arguments:
    arg 1 - 'rmi'
    arg 2 - name[req]
Stop container arguments:
    arg 1 - 'stop'
    arg 2 - name[req]

Quick docker start arguments: 
    arg 1 - 'q'
    arg 2 - name[req] 
        *container's name*
    arg 3 - interactive[opt]
        1 - Enable docker interaction
    arg 4 - restart[opt]
        1 - Restart docker if it's running
    "
# -------------------------------------------------
else 
    echo "
(for other commands: 'dockerStarter help')

Full containers list:
---------------------
"
    sudo docker ps -a --format "{{.Names}} {{.Status}}" | while read -r container status; do 
        if [[ "$status" == *"Up"* ]]; then 
            printf "%s - Active\n" "$container"
        else 
            printf "%s - Inactive\n" "$container"
        fi
    done
    echo "
---------------------
"
    read -p "Enter the container's name: " CONTAINERNAME

    # Check if any containers with the specified name exist
    existing_container=$(sudo docker ps -a --filter "name=$CONTAINERNAME" --format "{{.ID}}")

    if [ -n "$existing_container" ]; then
        read -p "Want to stop/remove the container (stop/rm/no): " STOP
        if [ "$STOP" == "rm" ]; then
            latest_stopped_container=$(sudo docker ps -a --filter "name=$CONTAINERNAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)
            if [ -n "$latest_stopped_container" ]; then
                sudo docker rm "$latest_stopped_container"
                echo "Container has been removed: $existing_container"
                exit 0
            else
                sudo docker stop "$existing_container"; sudo docker rm "$existing_container"
                echo "Container has been stopped and removed: $existing_container"
                exit 0
            fi
        elif [ "$STOP" == "stop" ]; then
            latest_stopped_container=$(sudo docker ps -a --filter "name=$CONTAINERNAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)

            if [ -n "$latest_stopped_container" ]; then
                sudo docker stop "$existing_container";
                echo "Container has been stopped: $existing_container"
                exit 0
            else 
                echo "Container $existing_container is already stopped."
                exit 0
            fi
        fi 

        read -p "Want to interact with the container (y/n): " INTERACTIVE
        # Find the latest stopped container with the specified name
        latest_stopped_container=$(sudo docker ps -a --filter "name=$CONTAINERNAME" --filter "status=exited" --format "{{.ID}}" | head -n 1)
        if [ -n "$latest_stopped_container" ]; then
            # Restart the latest stopped container
            echo "Starting the latest stopped container: $latest_stopped_container"
            if [ "$INTERACTIVE" == "y" ]; then
                sudo docker start -i "$latest_stopped_container"
                exit 0
            else
                sudo docker start "$latest_stopped_container"
                exit 0
            fi
        else
            # If no stopped containers, choose to restart or no
            running_container=$(sudo docker ps --filter "name=$CONTAINERNAME" --format "{{.ID}}" | head -n 1)
            read -p "The container is running, restart (y/n): " RESTART
            if [ "$RESTART" == "y" ]; then
                echo "Container is being restarted: $running_container"
                if [ "$INTERACTIVE" == "y" ]; then
                    sudo docker restart "$running_container"; sudo docker exec -it "$running_container" /bin/bash
                    exit 0
                else
                    sudo docker restart "$running_container"
                    echo "Container has been restarted: $running_container"
                    exit 0
                fi
            else 
                if [ "$INTERACTIVE" == "y" ]; then
                    echo "Entering container: $running_container"
                    sudo docker exec -it "$running_container" /bin/bash
                    exit 0
                else
                    echo "Container is already running: $running_container"
                    exit 0
                fi
            fi
        fi
    else
        # If no container exists with the specified name, create a new one
        image_id=$(sudo docker images --quiet "$CONTAINERNAME" | head -n 1)
        if [ -n "$image_id" ]; then
            read -p "Want to interact with the container (y/n): " INTERACTIVE
            echo "No container found with name $CONTAINERNAME. Creating a new container."
            if [ "$INTERACTIVE" == "y" ]; then
                sudo docker run -it --name "$CONTAINERNAME" "$CONTAINERNAME"
                exit 0
            else 
                sudo docker run --name "$CONTAINERNAME" "$CONTAINERNAME"
                echo "Container has been created: $CONTAINERNAME"
                exit 0
            fi
        else 
            echo "No container found with name $CONTAINERNAME. Cannot create a new container because the image doesn't exist."
            exit 1
        fi
    fi
fi
# -------------------------------------------------