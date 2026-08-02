FROM ubuntu:26.04

RUN apt-get update && apt-get install -y openssh-server python3
RUN mkdir -p /var/run/sshd
RUN echo 'root:screencast' | chpasswd

RUN sed -i -E \
    -e 's/^#?PermitRootLogin.*/PermitRootLogin yes/' \
    -e 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config \
    && grep -qx "PermitRootLogin yes" /etc/ssh/sshd_config \
    && grep -qx "PasswordAuthentication yes" /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]