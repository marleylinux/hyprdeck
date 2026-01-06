#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void sudo_cp(const char *source, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "sudo cp %s %s", source, destination);
    system(command);
}

void cp(const char *source, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "cp %s %s", source, destination);
    system(command);
}

void sudo_cp_r(const char *source, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "sudo cp -r %s %s", source, destination);
    system(command);
}

void cp_r(const char *source, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "cp -r %s %s", source, destination);
    system(command);
}

void sudo_tar_extract(const char *archive, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "sudo tar -xf %s -C %s", archive, destination);
    system(command);
}

void sudo_unzip_move(const char *archive, const char *destination) {
    char command[1024];
    snprintf(command, sizeof(command), "sudo unzip -q %s && sudo cp -r catppuccin-mocha-dark-cursors %s", archive, destination);
    system(command);
}

const char* get_current_directory() {
    static char cwd[1024];
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        return cwd;
    } else {
        perror("\033[33mgetcwd\033[0m \033[31mfailed\033[0m");
        return NULL;
    }
}

void install_pictures(const char *username) {
    printf("\033[33mInstalling\033[0m \033[34mPictures...\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s", username);

    cp_r("Pictures", destination);
}

void install_bashrc(const char *username) {
    printf("\033[33mInstalling\033[0m \033[36m.bashrc...\033[0m\n");
    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.bashrc", username);
    cp("bashrc", destination);  // ✅ Now it works!
}

void install_vimrc(const char *username) {
    printf("\033[33mInstalling\033[0m .vimrc...\n");
    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.vimrc", username);
    cp("vimrc", destination);  // ✅ Fixed
}


void install_pacman_conf(const char *username) {
    printf("\033[33mInstalling\033[0m \033[36mpacman.conf...\033[0m\n");
    sudo_cp("pacman.conf", "/etc");
}

void install_cpupower(const char *username) {
    printf("\033[33mInstalling\033[0m \033[36mcpupower...\033[0m\n");
    sudo_cp("cpupower", "/etc/default");
    system("sudo cpupower frequency-set -g performance");
}

void install_nwg_panel(const char *username) {
    printf("\033[33mInstalling\033[0m \033[35mnwg-panel...\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.config", username);

    cp_r("nwg-panel", destination);
}


void install_nwg_drawer(const char *username) {
    printf("\033[33mInstalling\033[0m \033[35mnwg-drawer...\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.config", username);

    cp_r("nwg-drawer", destination);
}


void install_nwg_bar(const char *username) {
    printf("\033[33mInstalling\033[0m \033[35mnwg-bar...\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.config", username);

    cp_r("nwg-bar", destination);
}


void install_mangohud(const char *username) {
    printf("\033[33mInstalling\033[0m \033[33mMangoHud...\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.config", username);

    cp_r("MangoHud", destination);
}

void install_hypr(const char *username) {
    printf("\033[33mInstalling\033[0m \033[36mhypr\033[0m\n");

    char destination[1024];
    snprintf(destination, sizeof(destination), "/home/%s/.config", username);

    cp_r("hypr", destination);
}


void install_nwg_hello(const char *username) {
    printf("\033[33mInstalling\033[0m \033[31mnwg-hello...\033[0m\n");
    sudo_cp_r("nwg-hello", "/etc");
    sudo_cp_r("greetd", "/etc");

    printf("\033[33mInstalling\033[0m \033[31mgirl.png...\033[0m\n");
    sudo_cp("girl.png", "/usr/share/nwg-hello");
}


void install_adw_gtk3(const char *username) {
    printf("\033[33mInstalling\033[0m \033[32madw-gtk3v5.6.tar.xz...\033[0m\n");
    sudo_tar_extract("adw-gtk3v5.6.tar.xz", "/usr/share/themes");
}

void install_catppuccin_cursors(const char *username) {
    printf("\033[33mInstalling\033[0m \033[32mcatppuccin-mocha-dark-cursors.zip...\033[0m\n");
    sudo_unzip_move("catppuccin-mocha-dark-cursors.zip", "/usr/share/icons");
}

void remove_source_directory() {
    char choice;
    char cwd[1024];

    if (getcwd(cwd, sizeof(cwd)) == NULL) {
        perror("Error getting current directory");
        return;
    }

    // Ensure it's the "dotfiles" directory
    if (strstr(cwd, "dotfiles") == NULL) {
        printf("\033[31mAbort:\033[0m Not in a 'dotfiles' directory!\n");
        return;
    }

    printf("\033[33mDo you want to\033[0m \033[31mremove\033[0m \033[33mthe source\033[0m \033[36mdotfiles\033[0m \033[35mdirectory\033[0m \033[32m(y/\033[0m\033[31mn):\033[0m ");
    scanf(" %c", &choice);

    if (choice == 'y' || choice == 'Y') {
        printf("\033[31mConfirm deletion of\033[0m \033[36m%s\033[0m \033[31m(y/n)?\033[0m ", cwd);
        scanf(" %c", &choice);

        if (choice == 'y' || choice == 'Y') {
            char command[1024];
            snprintf(command, sizeof(command), "sudo rm -rf %s", cwd);
            system(command);
            printf("\033[33mSource\033[0m \033[36mdotfiles\033[0m \033[33mDirectory removed\033[0m\n");
        } else {
            printf("\033[33mDeletion cancelled.\033[0m\n");
        }
    } else {
        printf("\033[33mSource\033[0m \033[36mdotfiles\033[0m \033[33mDirectory retained\033[0m\n");
    }
}

int main() {
    char username[256];
    printf("\033[36mEnter\033[0m \033[33myour\033[0m \033[31musername\033[0m: ");
    scanf("%s", username);
    while (getchar() != '\n');
    
    printf("\033[31mWelcome to the\033[0m \033[36mdotfiles\033[0m \033[33mInstaller!\033[0m\n");
    printf("\033[32mChoose the\033[0m \033[36mdotfiles\033[0m \033[33mto install\033[0m \033[31m(separate by space,\033[0m \033[32m;e.g., 1 5 6):\033[0m \n");
    printf("\033[31m1.\033[0m \033[35mInstall\033[0m \033[36mPictures\033[0m\n");
    printf("\033[33m2.\033[0m \033[32mInstall\033[0m \033[36m.bashrc\033[0m\n");
    printf("\033[32m3.\033[0m \033[33mInstall\033[0m \033[32m.vimrc\033[0m\n");
    printf("\033[34m4.\033[0m \033[31mInstall\033[0m \033[36mpacman.conf\033[0m\n");
    printf("\033[35m5.\033[0m \033[36mInstall\033[0m \033[34mcpupower (set to 4.5GHz - 4.9GHz dont use if too high)\033[0m\n");
    printf("\033[36m6.\033[0m \033[34mInstall\033[0m \033[35mnwg-panel\033[0m\n");
    printf("\033[31m7.\033[0m \033[32mInstall\033[0m \033[35mnwg-drawer\033[0m\n");
    printf("\033[33m8.\033[0m \033[33mInstall\033[0m \033[35mnwg-bar\033[0m\n");
    printf("\033[32m9.\033[0m \033[31mInstall\033[0m \033[33mmangohud\033[0m\n");
    printf("\033[34m10.\033[0m \033[35mInstall\033[0m \033[36mhypr\033[0m\n");
    printf("\033[35m11.\033[0m \033[33mInstall\033[0m \033[31mnwg-hello\033[0m\n");
    printf("\033[36m12.\033[0m \033[36mInstall\033[0m \033[33madw-gtk3\033[0m\n");
    printf("\033[31m13.\033[0m \033[34mInstall\033[0m \033[33mcatppuccin-mocha-dark-cursors\033[0m\n");
    
    char input[1024];
    printf("\033[32mEnter\033[0m \033[35mthe\033[0m \033[34mnumbers\033[0m \033[36mseperated\033[0m \033[33mby\033[0m \033[31mspaces\033[0m ");
    fgets(input, sizeof(input), stdin);
    
    char *token = strtok(input, " ");
    while (token != NULL) {
        int choice = atoi(token);
        switch (choice) {
            case 1: install_pictures(username); break;
            case 2: install_bashrc(username); break;
            case 3: install_vimrc(username); break;
            case 4: install_pacman_conf(username); break;
            case 5: install_cpupower(username); break;
            case 6: install_nwg_panel(username); break;
            case 7: install_nwg_drawer(username); break;
            case 8: install_nwg_bar(username); break;
            case 9: install_mangohud(username); break;
            case 10: install_hypr(username); break;
            case 11: install_nwg_hello(username); break;
            case 12: install_adw_gtk3(username); break;
            case 13: install_catppuccin_cursors(username); break;
            default: printf("Invalid choice: %d\n", choice); break;
        }
        token = strtok(NULL, " ");
    }
    
    printf("\033[32mInstallation\033[0m \033[35mfinished\033[0m\n");
    getchar();

    remove_source_directory();
    return 0;
}
