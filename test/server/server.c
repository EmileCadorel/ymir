#include <sys/socket.h>
#include <arpa/inet.h>

int my_bind (int socket, int family, int port, int s_addr) {
    struct sockaddr_in self;
    bzero (&self, sizeof (self));
    self.sin_family = family;
    self.sin_port = htons (port);
    self.sin_addr.s_addr = INADDR_ANY;
    
    return bind (socket, (struct sockaddr*) &self, sizeof (self));
}

int my_accept (int socket, char ** addr, int * port) {
    struct sockaddr_in client_addr;
    int addrlen = sizeof (client_addr);
    int clientfd = accept (socket, (struct sockaddr*) &client_addr, &addrlen);
    
    *addr =  inet_ntoa (client_addr.sin_addr);
    *port = ntohs (client_addr.sin_port);
    return clientfd;
}
