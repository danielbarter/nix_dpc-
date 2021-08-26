#include <CL/sycl.hpp>

using namespace sycl;


int main() {
  for (auto device : device::get_devices(info::device_type::gpu)) {
    std::cout << "  Device: "
	      << device.get_info<info::device::name>()
	      << std::endl;
  }
}
