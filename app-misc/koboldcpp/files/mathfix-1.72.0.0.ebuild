diff --git a/Makefile b/Makefile
index d0d9aa2e..8ee6e865 100644
--- a/Makefile
+++ b/Makefile
@@ -42,8 +42,8 @@ endif
 #
 
 # keep standard at C11 and C++11
-CFLAGS   = -I. -Iggml/include -Iggml/src -Iinclude -Isrc -I./include -I./include/CL -I./otherarch -I./otherarch/tools -I./otherarch/sdcpp -I./otherarch/sdcpp/thirdparty -I./include/vulkan -O3 -fno-finite-math-only -fmath-errno -DNDEBUG -std=c11   -fPIC -DLOG_DISABLE_LOGS -D_GNU_SOURCE -DGGML_USE_LLAMAFILE
-CXXFLAGS = -I. -Iggml/include -Iggml/src -Iinclude -Isrc -I./common -I./include -I./include/CL -I./otherarch -I./otherarch/tools -I./otherarch/sdcpp -I./otherarch/sdcpp/thirdparty -I./include/vulkan -O3 -fno-finite-math-only -fmath-errno -DNDEBUG -std=c++11 -fPIC -DLOG_DISABLE_LOGS -D_GNU_SOURCE -DGGML_USE_LLAMAFILE
+CFLAGS   = -I. -Iggml/include -Iggml/src -Iinclude -Isrc -I./include -I./include/CL -I./otherarch -I./otherarch/tools -I./otherarch/sdcpp -I./otherarch/sdcpp/thirdparty -I./include/vulkan -O3 -fno-finite-math-only -DNDEBUG -std=c11   -fPIC -DLOG_DISABLE_LOGS -D_GNU_SOURCE -DGGML_USE_LLAMAFILE
+CXXFLAGS = -I. -Iggml/include -Iggml/src -Iinclude -Isrc -I./common -I./include -I./include/CL -I./otherarch -I./otherarch/tools -I./otherarch/sdcpp -I./otherarch/sdcpp/thirdparty -I./include/vulkan -O3 -fno-finite-math-only -DNDEBUG -std=c++11 -fPIC -DLOG_DISABLE_LOGS -D_GNU_SOURCE -DGGML_USE_LLAMAFILE
 LDFLAGS  =
 #CC         := gcc-13
 #CXX        := g++-13
