# Get the base image

FROM scientificlinux/sl:6 as builder

MAINTAINER Simone Sciabola <simone.sciabola@biogen.com>

COPY sl6_repos/ /etc/yum.repos.d/

# Create pfred directory

WORKDIR /home/pfred/

# Locate myself at home

RUN cd /home && mkdir /home/pfred/bin

# Install dependencies then clean up cache

RUN yum update

RUN yum install -y perl \
  wget \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  python-devel \
  readline-devel \
  zlib-devel \
  perl-DBI \
  perl-DBD-mysql && \
  yum clean all

RUN cd /home/ && \
  wget --no-check-certificate  https://sourceforge.net/projects/numpy/files/NumPy/1.4.1/numpy-1.4.1.tar.gz && \
  wget --no-check-certificate  https://cran.r-project.org/src/base/R-2/R-2.6.0.tar.gz && \
  wget --no-check-certificate  https://sourceforge.net/projects/rpy/files/rpy/1.0.2/rpy-1.0.2.tar.gz && \
  for f in *.tar.gz; do tar -xvf "$f"; done && \
  wget --no-check-certificate  https://cran.r-project.org/src/contrib/Archive/pls/pls_2.1-0.tar.gz && \
  wget --no-check-certificate  https://cran.r-project.org/src/contrib/Archive/randomForest/randomForest_4.6-10.tar.gz && \
  wget --no-check-certificate  https://cran.r-project.org/src/contrib/Archive/e1071/e1071_1.5-27.tar.gz && \
  cd /home/numpy-1.4.1 && \
  python setup.py build --fcompiler=gnu95 && python setup.py install --prefix=/home/pfred/bin/numpy && \
  cd /home/R-2.6.0 && \
  ./configure --prefix=/home/pfred/bin/R2.6.0 --enable-R-shlib --with-x=no && make && \
  make check && make install

# Library variables

RUN echo "export PATH=/home/pfred/bin/R2.6.0/bin:$PATH" >> ~/.bashrc && \
  echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/pfred/bin/R2.6.0/bin" >> ~/.bashrc && \
  echo "export RHOMES='/home/pfred/bin/R2.6.0/lib64/R'" >> ~/.bashrc && \
  echo "export PYTHONPATH=/home/pfred/bin/site-packages:/home/pfred/bin/site-packages/rpy:$PYTHONPATH" >> ~/.bashrc

# Download and install R packages: rpy, pls, rf, e1071

RUN source ~/.bashrc && \
  cd /home/rpy-1.0.2 && \
  python setup.py install --prefix=/home/pfred/bin/rpy && \
  cd /home/ && \
  R CMD INSTALL pls_2.1-0.tar.gz && \
  R CMD INSTALL randomForest_4.6-10.tar.gz && \
  R CMD INSTALL e1071_1.5-27.tar.gz

WORKDIR /home/pfred/bin/site-packages

RUN mkdir rpy

RUN mv /home/pfred/bin/numpy/lib64/python2.6/site-packages/numpy . && \
  mv /home/pfred/bin/rpy/lib64/python2.6/site-packages/* rpy && \
  rm -rf /home/pfred/bin/{numpy,rpy}

FROM scientificlinux/sl:6 as pfredenv
COPY sl6_repos/ /etc/yum.repos.d/

# Create pfred directory

WORKDIR /home/pfred/

# Install java using yum. TODO: Use yum remove to remove unnecessary dependencies

RUN yum install -y java perl perl-DBI perl-DBD-mysql wget libgfortran libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver && yum clean all

COPY --from=builder /home/pfred/bin /home/pfred/bin
COPY --from=builder /root/.bashrc /root/.bashrc

# Install python3 

RUN cd /home/pfred/ && \
    wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh && \
    bash Anaconda3-2021.05-Linux-x86_64.sh -b && \
    rm -f Anaconda3-2021.05-Linux-x86_64.sh && \
    echo "export PATH=/root/anaconda3/bin:$PATH" >> ~/.bashrc && \
    source /root/.bashrc && \
    conda install importlib_resources && \
    conda install simplejson

# Create the scripts and scratch directory

RUN source /root/.bashrc && mkdir scripts scratch

# Get libraries from github

COPY ./entrypoint.sh entrypoint.sh

COPY ./setup_env.sh setup_env.sh

RUN chmod a+x entrypoint.sh && chmod a+x setup_env.sh

ENTRYPOINT ["./entrypoint.sh"]

