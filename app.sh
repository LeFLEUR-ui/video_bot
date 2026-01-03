RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

LOGFILE="$HOME/video_bot.log"

update_system() {
    echo -e "${CYAN}[*] Updating system...${RESET}" | tee -a "$LOGFILE"
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y
    echo -e "${GREEN}[*] System update complete!${RESET}" | tee -a "$LOGFILE"
}

install_downloader() {
    if ! command -v yt-dlp &> /dev/null; then
        echo -e "${CYAN}[*] Installing yt-dlp...${RESET}" | tee -a "$LOGFILE"
        sudo apt install -y python3-pip
        pip3 install --upgrade yt-dlp
        echo -e "${GREEN}[*] yt-dlp installed successfully!${RESET}" | tee -a "$LOGFILE"
    else
        echo -e "${YELLOW}[*] yt-dlp is already installed.${RESET}" | tee -a "$LOGFILE"
    fi
}

download_video() {
    read -p "$(echo -e ${CYAN}Enter video URL:${RESET} )" url
    read -p "$(echo -e ${CYAN}Enter download folder (default ~/Downloads/Videos):${RESET} )" folder
    folder=${folder:-"$HOME/Downloads/Videos"}
    mkdir -p "$folder"

    echo -e "${CYAN}Select video quality:${RESET}"
    echo -e "1) best\n2) 1080p\n3) 720p\n4) 480p\n5) audio only"
    read -p "$(echo -e ${CYAN}Choose an option [1-5]:${RESET} )" quality_choice

    case $quality_choice in
        1) quality="best" ;;
        2) quality="bestvideo[height<=1080]+bestaudio/best" ;;
        3) quality="bestvideo[height<=720]+bestaudio/best" ;;
        4) quality="bestvideo[height<=480]+bestaudio/best" ;;
        5) quality="bestaudio" ;;
        *) quality="best" ;;
    esac

    site=$(echo "$url" | awk -F/ '{print $3}')
    folder="$folder/$(date +%Y-%m-%d)/$site"
    mkdir -p "$folder"

    echo -e "${CYAN}[*] Downloading video...${RESET}" | tee -a "$LOGFILE"
    yt-dlp -f "$quality" -o "$folder/%(title)s.%(ext)s" "$url"
    echo -e "${GREEN}[*] Download complete! Saved in $folder${RESET}" | tee -a "$LOGFILE"
}

batch_download() {
    read -p "$(echo -e ${CYAN}Enter path to file with URLs:${RESET} )" file
    if [[ ! -f $file ]]; then
        echo -e "${RED}[!] File not found.${RESET}" | tee -a "$LOGFILE"
        return
    fi
    while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        echo -e "${YELLOW}[*] Processing $url${RESET}" | tee -a "$LOGFILE"
        download_video <<< "$url"
    done < "$file"
}

main_menu() {
    while true; do
        echo -e "${CYAN}==============================${RESET}"
        echo -e "${CYAN}        VIDEO BOT MENU        ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo -e "${YELLOW}[1] Update System${RESET}"
        echo -e "${YELLOW}[2] Install Video Downloader (yt-dlp)${RESET}"
        echo -e "${YELLOW}[3] Download Single Video${RESET}"
        echo -e "${YELLOW}[4] Batch Download from File${RESET}"
        echo -e "${YELLOW}[5] Exit${RESET}"
        echo -e "${CYAN}==============================${RESET}"

        read -p "$(echo -e ${CYAN}Choose an option [1-5]:${RESET} )" choice

        case $choice in
            1) update_system ;;
            2) install_downloader ;;
            3) download_video ;;
            4) batch_download ;;
            5) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice, try again.${RESET}" ;;
        esac
    done
}

main_menu

