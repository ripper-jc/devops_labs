#include <iostream>

#include <sys/wait.h>
#include "FuncA.h"

int CreateHTTPserver();

void sigchldHandler(int s) {
    printf("SIGCHLD received\n");
    pid_t pid;
    int status;

    while((pid = waitpid(-1, &status, WNOHANG)) > 0);
    {
        if (WIFEXITED(status)) {
            printf("Child %d terminated with status: %d\n", pid, WEXITSTATUS(status));
        } else {
            printf("Child %d terminated abnormally\n", pid);
        }
    }
}

void siginHandler(int s) {
    printf("Caught signal %d\n", s);
    pid_t pid;
    int status;
    while((pid = waitpid(-1, &status, 0)) > 0);
    {
        if (WIFEXITED(status)) {
            printf("Child %d terminated with status: %d\n", pid, WEXITSTATUS(status));
        } else {
            printf("Child %d terminated abnormally\n", pid);
        }
        if (pid == -1) {
            printf("No more child processes\n");
        }
    }
}


int main() {
    
    signal(SIGCHLD, sigchldHandler);
    signal(SIGINT, siginHandler);

    FuncA calc;
    // double x = 1.0; // Example value for x
    // int n = 10; // Example value for n
    // std::cout << "FuncA result: " << calc.calculate(x, n) << std::endl;


    CreateHTTPserver();


    return 0;
}
