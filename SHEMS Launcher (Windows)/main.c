/*
    Live Server on port 30000
*/
#include <io.h>
#include <stdio.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <string.h>
#include <sys/stat.h>

//#define DEFAULT_BUFLEN 512
#define DEFAULT_BUFLEN 1048576
#define PORT_NUM 30000
#define SAMPLING_RATE 16000

//#pragma comment(lib,"ws2_32.lib") //Winsock Library

int recvAll(int socket, void *buffer, size_t length, int flags, int timeIdle);

int main(int argc , char *argv[])
{
    WSADATA wsa;
    SOCKET s , new_socket;
    struct sockaddr_in server , client;
    int c;
    int iResult;
    //char *message = "Yeah, Joe.\n";
    char recvbuf[DEFAULT_BUFLEN];
    //int recvbuflen = DEFAULT_BUFLEN;
    int numSamplesPerFile = SAMPLING_RATE*10;
    FILE *dataFile;

    memset(recvbuf, '\0', sizeof(recvbuf));
    //struct addrinfo *result = NULL;
    //struct addrinfo hints;

    printf("\nInitialising Winsock...");
    if (WSAStartup(MAKEWORD(2,2),&wsa) != 0)
    {
        printf("Failed. Error Code : %d", WSAGetLastError());
        return 1;
    }
    printf("Initialised.\n");

    //Create a socket
    if((s = socket(AF_INET , SOCK_STREAM , 0 )) == INVALID_SOCKET)
    {
        printf("Could not create socket : %d" , WSAGetLastError());
    }

    printf("Socket created.\n");

    // Read the numRun file, increment the value, and rewrite it.
    FILE    *fileNumRun;
    int     numRun;
    fileNumRun = fopen("numRun.txt", "r");
    if (fileNumRun == NULL) {
        printf("ERR - failed to read numRun.txt.\n");
        closesocket(s);
        WSACleanup();
        return -1;
    }
    fscanf(fileNumRun, "%d", &numRun);
    numRun += 1;
    fclose(fileNumRun);
    fileNumRun = fopen("numRun.txt", "w");
    if (fileNumRun == NULL) {
        printf("ERR - failed to write numRun.txt.\n");
        closesocket(s);
        WSACleanup();
        return -1;
    }
    fprintf(fileNumRun, "%03d", numRun);
    numRun -= 1;
    fclose(fileNumRun);

    // Create a folder to store the results of this run.
    char folderName[200];
    int error_mkdir;
    sprintf(folderName, "results_%03d", numRun);
    error_mkdir = mkdir(folderName);
    if (error_mkdir == -1) {
        printf("ERR - failed to create folder: %s", folderName);
        closesocket(s);
        WSACleanup();
        return -1;
    }


    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( PORT_NUM );

    //Bind
    if( bind(s ,(struct sockaddr *)&server , sizeof(server)) == SOCKET_ERROR)
    {
        printf("Bind failed with error code : %d" , WSAGetLastError());
        exit(EXIT_FAILURE);
    }

    puts("Bind done");

    //Listen to incoming connections
    listen(s , 3);

    //Accept and incoming connection
    puts("Waiting for incoming connections...");

    c = sizeof(struct sockaddr_in);
    new_socket = accept(s , (struct sockaddr *)&client, &c);

    if (new_socket == INVALID_SOCKET)
    {
        printf("accept failed with error code : %d" , WSAGetLastError());
        return 1;
    }
    puts("Connection accepted");

    //int counterSleep = 0;
    int counter = 1;
    char fileName[200] = "";
    while (1) {
        iResult = recvAll(new_socket, recvbuf, numSamplesPerFile, 0, 10000);
        if (iResult == -1) return -1;
        if (iResult == 0) {
            printf("main loop exited correctly with empty file\n");
            break;
        }
        sprintf(fileName, "results_%03d\\power_%03d_%05d.csv", numRun, numRun, counter);
        counter += 1;
        dataFile = fopen(fileName, "w");
        if (dataFile == NULL) {
            printf("ERR - %s did not open correctly\n", fileName);
            closesocket(s);
            WSACleanup();
            return -1;
        }
        fprintf(dataFile, "%s", recvbuf);
        fclose(dataFile);
        if (iResult == 0) {
            printf("main loop exited correctly with partial file\n");
            break;
        }
        memset(recvbuf, '\0', sizeof(recvbuf));
    }

    closesocket(s);
    WSACleanup();
    printf("End Program\n");

    return 0;
}


int recvAll(int socket, void *buffer, size_t length, int flags, int timeIdle) {
    // Note: timeIdle is in milliseconds
    // Return values:   -1: error
    //                   0: sleep timed out
    //                   1: successful read
    //                   2: partial file

    int     numBytesReceived = 0;
    int     counterSleepCycles = 0;
    int     prevValue = -1;
    int     lengthOriginal = length;
    float   timeSleepEachCycle = 150;
    float   numCyclesSleep = timeIdle / timeSleepEachCycle;

    if (length <= 0) {
        printf("ERR - length <= 0\n");
        return -1;
    }
    while (length > 0) {
        numBytesReceived = recv(socket, buffer, length, flags);
        buffer += numBytesReceived;
        length -= numBytesReceived;
        printf("Bytes Received:\t%d\n", numBytesReceived);

        if (prevValue == numBytesReceived) counterSleepCycles += 1;
        else counterSleepCycles = 0;
        if (counterSleepCycles >= (int)numCyclesSleep) {
            if (length == lengthOriginal) {
                printf("recvAll received nothing\n");
                return -1;
            }
            printf("recvAll received a partial file\n");
            return 0;
        }
        prevValue = numBytesReceived;

        Sleep((int)timeSleepEachCycle);
    }
    if (length != 0) {
        printf("ERR - recvAll vague error\n");
        return -1;
    }
    printf("Full buffer received\t%d\n", lengthOriginal);
    return 1;
}
