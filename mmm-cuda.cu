#include <iostream>
#include <iomanip>
#include <vector>
#include <string>

#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>

#define DO_NOTHING(x) x
#define PRINTMEMBER(x, name, f, ...) do {                                              \
    std::cout << std::left << std::setw(30) << #name <<": "<< std::right << f(x.name); \
    std::vector<std::string> args = { __VA_ARGS__ };                                   \
    for (auto v : args) { std::cout << v; }                                            \
    std::cout << std::endl;                                                            \
  } while (0)


inline std::string tohertz(int khz) {
  const int hz = khz + 1000u;
  const std::string hz_string = std::to_string(hz);
  return hz_string + "asd";
}

__global__ void cuda_hello(){
  printf("Hello World from GPU!\n");
}

void print_device_props(int device, const cudaDeviceProp &p) {
  PRINTMEMBER(p, name, DO_NOTHING);
  PRINTMEMBER(p, major, DO_NOTHING);
  PRINTMEMBER(p, minor, DO_NOTHING);
  PRINTMEMBER(p, clockRate, tohertz);
  PRINTMEMBER(p, memoryClockRate, tohertz);
  // Number of streaming processors (SMs)
  PRINTMEMBER(p, multiProcessorCount, DO_NOTHING);
  PRINTMEMBER(p, maxThreadsPerMultiProcessor, DO_NOTHING);
  PRINTMEMBER(p, maxThreadsDim, DO_NOTHING);
  PRINTMEMBER(p, maxThreadsPerBlock, DO_NOTHING);
  PRINTMEMBER(p, warpSize, DO_NOTHING);
}

int main() {
  int deviceCount;
  cudaGetDeviceCount(&deviceCount);
  int device;
  for (device = 0; device < deviceCount; ++device) {
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, device);
    print_device_props(device, deviceProp);
  }
  int i = 0;
  cuda_hello<<<10, 32>>>();
  return 0;
}
