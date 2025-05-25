#!/bin/bash
# Helper script for MTProxy

# Function to display usage
show_help() {
    echo "MTProxy Docker Helper"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start         Start the MTProxy service"
    echo "  stop          Stop the MTProxy service"
    echo "  restart       Restart the MTProxy service"
    echo "  socks5        Configure SOCKS5 proxy settings"
    echo "  status        Show proxy status"
    echo "  secret        Display the current proxy secret"
    echo "  link          Generate Telegram proxy link (requires IP address)"
    echo "  logs          Show container logs"
    echo "  update        Update the MTProxy image"
    echo "  help          Show this help message"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
}

# Function to get server IP
get_ip() {
    echo "Please enter your server's public IP address:"
    read -r IP_ADDRESS
    
    if [ -z "$IP_ADDRESS" ]; then
        echo "IP address cannot be empty."
        exit 1
    fi
    
    echo "$IP_ADDRESS"
}

# Main command processing
case "$1" in
    start)
        check_docker
        docker-compose up -d
        echo "MTProxy started."
        ;;
        
    stop)
        check_docker
        docker-compose down
        echo "MTProxy stopped."
        ;;
        
    restart)
        check_docker
        docker-compose down
        docker-compose up -d
        echo "MTProxy restarted."
        ;;
        
    status)
        check_docker
        echo "MTProxy container status:"
        docker-compose ps
        
        echo -e "\nMTProxy Statistics:"
        curl -s http://localhost:8888/stats 2>/dev/null || echo "Stats service not accessible. Make sure the proxy is running."
        ;;
        
    secret)
        check_docker
        echo "Your MTProxy secret is:"
        docker-compose exec mtproxy cat /data/secret 2>/dev/null || echo "Failed to get secret. Make sure the proxy is running."
        ;;
        
    link)
        check_docker
        IP=$(get_ip)
        SECRET=$(docker-compose exec -T mtproxy cat /data/secret 2>/dev/null)
        
        if [ -z "$SECRET" ]; then
            echo "Failed to get secret. Make sure the proxy is running."
            exit 1
        fi
        
        echo -e "\nTelegram Proxy Links:"
        echo "Standard link:"
        echo "tg://proxy?server=$IP&port=443&secret=$SECRET"
        
        echo -e "\nLink with random padding (recommended):"
        echo "tg://proxy?server=$IP&port=443&secret=dd$SECRET"
        
        echo -e "\nHTTPS link (for sharing):"
        echo "https://t.me/proxy?server=$IP&port=443&secret=dd$SECRET"
        ;;
        
    logs)
        check_docker
        docker-compose logs -f
        ;;
        
    socks5)
        check_docker
        echo "Configure SOCKS5 proxy for MTProxy"
        echo "Enter SOCKS5 proxy details (format: server:port or server:port:username:password):"
        echo "Leave empty to disable SOCKS5 proxy"
        read -r SOCKS5_PROXY
        
        # Create or update .env file
        if [ -f .env ]; then
            grep -v "^SOCKS5_PROXY=" .env > .env.tmp && mv .env.tmp .env
        else
            touch .env
        fi
        
        if [ -n "$SOCKS5_PROXY" ]; then
            echo "SOCKS5_PROXY=$SOCKS5_PROXY" >> .env
            echo "SOCKS5 proxy configured: $SOCKS5_PROXY"
        else
            echo "SOCKS5 proxy disabled"
        fi
        
        # Restart for changes to take effect
        echo "Restarting MTProxy to apply changes..."
        docker-compose down
        docker-compose up -d
        ;;
        
    update)
        check_docker
        docker-compose pull
        docker-compose up -d
        echo "MTProxy updated to the latest version."
        ;;
        
    help|*)
        show_help
        ;;
esac
