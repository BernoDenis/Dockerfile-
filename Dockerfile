#Sistema operativo

FROM ubuntu:20.04

#Impostazione di Sistema neccessaria ad alcuni pacchetti

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Installazione pacchetti necessari a AWS e OPENCV 

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y -f  build-essential g++11 clang 
RUN apt-get install -y -f  --force-yes qemu-user-static 
RUN apt-get install -y -f   nano
RUN apt-get install -y -f  wget unzip git curl python python3-numpy python3-dev
RUN apt-get install -y -f  --force-yes libcurl4-openssl-dev libssl-dev uuid-dev 
RUN apt-get install -y -f  --force-yes zlib1g-dev libpulse-dev openssl software-properties-common
RUN apt-get install -y -f  --force-yes libboost-all-dev zlib1g zlib1g-dev
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt-get update 
RUN apt-get install -y -f libjasper1 libjasper-dev 
RUN apt-get install -y -f cmake git libgtk2.0-dev pkg-config libavcodec-dev 
RUN apt-get install -y -f libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev 
RUN apt-get install -y -f libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
RUN apt-get install -y -f libcurl4-openssl-dev  libtbb-dev libv4l-dev
RUN apt-get install -y -f libtiff5-dev libeigen3-dev libtheora-dev libvorbis-dev 
RUN apt-get install -y -f libxvidcore-dev libx264-dev sphinx-common 
RUN apt-get install -y -f libtbb-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev 
RUN apt-get install -y -f libopenexr-dev libgstreamer-plugins-base1.0-dev 
RUN apt-get install -y -f libavutil-dev libavfilter-dev libavresample-dev 
RUN apt-get install -y -f libgtk-3-dev "libcanberra-gtk*" 
RUN apt-get install -y -f gfortran openexr libatlas-base-dev libgstreamer1.0-dev
RUN apt-get install -y -f cmake 

#Installazione OPENCV 

RUN apt-get update 
RUN apt-get -y upgrade 
RUN apt-get install -y --force-yes libopencv-dev python3-opencv

WORKDIR /opt/
RUN mkdir opencv_build && cd opencv_build
WORKDIR /opt/opencv_build
RUN git clone https://github.com/opencv/opencv.git
RUN git clone https://github.com/opencv/opencv_contrib.git
RUN cd /opt/opencv_build/opencv
RUN mkdir -p build && cd build
WORKDIR cd /opt/opencv_build/opencv/build 

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D INSTALL_C_EXAMPLES=ON \
-D INSTALL_PYTHON_EXAMPLES=ON \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_build/opencv_contrib/modules \
-D BUILD_EXAMPLES=ON /opt/opencv_build/opencv

RUN make -j4
RUN make install
RUN ldconfig


#Installazione AWS (solo pacchetti core & s3)

WORKDIR /usr/local/
RUN git clone https://github.com/aws/aws-sdk-cpp
RUN mkdir build_dir
RUN cd build_dir
WORKDIR /usr/local/aws-sdk-cpp/
RUN cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
RUN make -j4 -C aws-cpp-sdk-core
RUN make -j4 -C aws-cpp-sdk-s3
RUN make install -C aws-cpp-sdk-core
RUN make install -C aws-cpp-sdk-s3
RUN ldconfig

#Trasferimento codice sorgente ed altre informazioni

RUN mkdir /source
COPY . /source
VOLUME ["/source"]
WORKDIR /source

ENV INPUT_FILE  "a.jpg"
ENV OUTPUT_FILE  "a_o.jpg"

RUN g++ -c $(pkg-config --cflags --libs opencv4) -laws-cpp-sdk-s3 -laws-cpp-sdk-core -std=c++11 main.cpp 
RUN g++ -o main main.o $(pkg-config --cflags --libs opencv4) -laws-cpp-sdk-s3 -laws-cpp-sdk-core -std=c++11 

#RUN ./main $input_name $output_name
ENTRYPOINT ./main ${INPUT_FILE} ${OUTPUT_FILE}


#ENTRYPOINT ffmpeg -i ${INPUT_VIDEO_FILE_URL} -ss ${POSITION_TIME_DURATION} -vframes 1 -vcodec png -an -y ${OUTPUT_THUMBS_FILE_NAME} && ./copy_thumbs.sh

#CMD ["./main" $input_name $output_name]












