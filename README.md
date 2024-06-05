This is one of my first bash scripts that i actually publish on github and it is meant to facilitate the constant management of many dockers. 

It provides simple quality of life features such as a guided mode so you don't need to constantly type the commands by yourself and other stuff. 

It can:
    - Quickly allow a person to interact with the needed docker;
    - Restart stopped dockers;
    - Start a docker using an image with the same name;
    - Remove container without the need of stopping it manually before
    - Stop a container
    - Remove an image
    - List active and inactive containers;
    - List all images;

EasyDockerManager commands (included also in "EasyDockerManager help"):

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

Feel free to use it just please credit me :)
