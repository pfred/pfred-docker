# Get the base image

FROM scientificlinux/sl:6 as builder

MAINTAINER Simone Sciabola <simone.sciabola@biogen.com>

# Create pfred directory

WORKDIR /home/pfred

ENV PFREDIR /home/pfred

# Locate myself at home

RUN cd /home && mkdir ${PFREDIR}/bin

# Install dependencies then clean up cache

RUN yum install -y perl \
  wget \
  gcc \
  gcc-c++ \
  gcc-gfortran \
  python-devel \
  readline-devel \
  mysql-devel \
  perl-DBI \
  perl-DBD-mysql && \
  yum clean all

# Download numpy, R, rpy, R modules
# untar everything
# Install numpy, R

RUN cd /home/ && \
  wget https://sourceforge.net/projects/numpy/files/NumPy/1.4.1/numpy-1.4.1.tar.gz && \
  wget https://cran.r-project.org/src/base/R-2/R-2.6.0.tar.gz && \
  wget https://sourceforge.net/projects/rpy/files/rpy/1.0.2/rpy-1.0.2.tar.gz && \
  for f in *.tar.gz; do tar -xvf "$f"; done && \
  wget https://cran.r-project.org/src/contrib/Archive/pls/pls_2.1-0.tar.gz && \
  wget https://cran.r-project.org/src/contrib/Archive/randomForest/randomForest_4.6-10.tar.gz && \
  wget https://cran.r-project.org/src/contrib/Archive/e1071/e1071_1.5-27.tar.gz && \
  cd /home/numpy-1.4.1 && \
  python setup.py build --fcompiler=gnu95 && python setup.py install --prefix=${PFREDIR}/bin/numpy && \
  cd /home/R-2.6.0 && \
  ./configure --prefix=${PFREDIR}/bin/R2.6.0 --enable-R-shlib --with-x=no && make && \
  make check && make install

# Library variables

RUN echo "export PATH=${PFREDIR}/bin/R2.6.0/bin:$PATH" >> ~/.bashrc && \
  echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PFREDIR}/bin/R2.6.0/bin" >> ~/.bashrc && \
  echo "export RHOMES='${PFREDIR}/bin/R2.6.0/lib64/R'" >> ~/.bashrc && \
  echo "export PYTHONPATH=${PFREDIR}/bin/site-packages:${PFREDIR}/bin/site-packages/rpy:$PYTHONPATH" >> ~/.bashrc

# Download and install R packages: rpy, pls, rf, e1071

RUN source ~/.bashrc && \
  cd /home/rpy-1.0.2 && \
  python setup.py install --prefix=${PFREDIR}/bin/rpy && \
  cd /home/ && \
  R CMD INSTALL pls_2.1-0.tar.gz && \
  R CMD INSTALL randomForest_4.6-10.tar.gz && \
  R CMD INSTALL e1071_1.5-27.tar.gz

WORKDIR ${PFREDIR}/bin/site-packages

RUN mkdir rpy

RUN mv ${PFREDIR}/bin/numpy/lib64/python2.6/site-packages/numpy . && \
  mv ${PFREDIR}/bin/rpy/lib64/python2.6/site-packages/* rpy && \
  rm -rf ${PFREDIR}/bin/{numpy,rpy}

# python3 dependencies

RUN yum -y install tk-devel gdbm-devel zlib-devel libffi libffi-devel && \
  yum clean all

# Install OpenSSl

RUN cd /usr/src && \
  curl https://www.openssl.org/source/openssl-1.0.2o.tar.gz | tar xz && \
  cd openssl-1.0.2o && \
  ./config shared --prefix=/usr/local/ && \
  make && \
  make install && \
  mkdir lib && \
  cp ./*.{so,so.1.0.0,a,pc} ./lib

# Install python3 and modules needed

RUN cd /tmp && \
  echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/src/openssl-1.0.2o/" >> /root/.bashrc && \
  source /root/.bashrc && \
  export LDFLAGS="-L/usr/src/openssl-1.0.2o/lib" && \
  wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz && \
  tar zxvf Python-3.7.4.tgz && \
  cd Python-3.7.4 && \
  ./configure --prefix=${PFREDIR}/bin/python-3.7.4 && \
  make && make install && \
  echo "export PATH=${PFREDIR}/bin/python-3.7.4/bin:\$PATH" >> /root/.bashrc && \
  source /root/.bashrc && \
  pip3 install importlib_resources requests scrapy simplejson intervaltree natsort tqdm && \
  cp -r /usr/src/openssl-1.0.2o ${PFREDIR}/bin

FROM scientificlinux/sl:6 as pfredenv

# Create pfred directory

WORKDIR /home/pfred

ENV PFREDIR /home/pfred

# Install java using yum. TODO: Use yum remove to remove unnecessary dependencies

RUN yum install -y java perl perl-DBI perl-DBD-mysql wget libgfortran && yum clean all

COPY --from=builder ${PFREDIR}/bin ${PFREDIR}/bin
COPY --from=builder /root/.bashrc /root/.bashrc

# Create the scripts and scratch directory

RUN source /root/.bashrc && mkdir scripts scratch

# Get libraries from github

COPY entrypoint.sh entrypoint.sh

COPY setup_env.sh setup_env.sh

RUN chmod a+x entrypoint.sh && chmod a+x setup_env.sh
RUN mv ${PFREDIR}/bin/openssl-1.0.2o /usr/src

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
