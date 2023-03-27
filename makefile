#=================================================================================
#=================================================================================
# Compiler?
#Possible values: (Empty: gfortran)
#                gfortran (version: 9.0 linux and osx)
# F90 = mpifort
 FC = gfortran
#
# Optimize? Empty: default No optimization; 0: No Optimization; 1 Optimzation
OPT = 1
## OpenMP? Empty: default with OpenMP; 0: No OpenMP; 1 with OpenMP
OMP = 1
## Lapack/blas/mkl? Empty: default with Lapack; 0: without Lapack; 1 with Lapack
LAPACK = 1
## force the default integer (without kind) during the compillation.
## default 4: , INT=8 (for kind=8)
INT = 4
#
## how to get external libraries;  "loc" (default): from local zip file, Empty or something else (v0.5): from github
EXTLIB_TYPE = loc
#=================================================================================
#=================================================================================
ifeq ($(FC),)
  FFC      := gfortran
else
  FFC      := $(FC)
endif
ifeq ($(OPT),)
  OOPT      := 1
else
  OOPT      := $(OPT)
endif
ifeq ($(OMP),)
  OOMP      := 1
else
  OOMP      := $(OMP)
endif
ifeq ($(LAPACK),)
  LLAPACK      := 1
else
  LLAPACK      := $(LAPACK)
endif
#===============================================================================
# setup for mpifort
ifeq ($(FFC),mpifort)
  ## MPI compiled with: gfortran or ifort
  MPICORE := $(shell ompi_info | grep 'Fort compiler:' | awk '{print $3}')
  OOMP = 0
endif
#===============================================================================
#
# Operating system, OS? automatic using uname:
OS :=$(shell uname)

# about EVRT, path, versions ...:
PhysCte_path:= $(shell pwd)

# Extension for the object directory and the library
ifeq ($(FFC),mpifort)
  extlibwi_obj:=_$(FFC)_$(MPICORE)_opt$(OOPT)_omp$(OOMP)_lapack$(LLAPACK)_int$(INT)
else
  extlibwi_obj:=_$(FFC)_opt$(OOPT)_omp$(OOMP)_lapack$(LLAPACK)_int$(INT)
endif
extlib_obj:=_$(FFC)_opt$(OOPT)_omp$(OOMP)_lapack$(LLAPACK)



OBJ_DIR = obj/obj$(extlibwi_obj)
$(info ***********OBJ_DIR:            $(OBJ_DIR))
$(shell [ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR))
MOD_DIR=$(OBJ_DIR)
#
# library name
LIBA=libPhysConst$(extlibwi_obj).a
#=================================================================================
# cpp preprocessing
CPPSHELL = -D__PHYSCTEPATH="'$(PhysCte_path)'"
#===============================================================================
#
#===============================================================================
# external lib (QDUtil)
ifeq ($(ExtLibDIR),)
  ExtLibDIR := $(PhysCte_path)/Ext_Lib
endif

QD_DIR    = $(ExtLibDIR)/QDUtilLib
QDMOD_DIR = $(QD_DIR)/OBJ/obj$(extlib_obj)
QDLIBA    = $(QD_DIR)/libQD$(extlib_obj).a

EXTLib     = $(QDLIBA)
#===============================================================================
#===============================================================================
#===============================================================================
# gfortran (osx and linux)
#ifeq ($(F90),gfortran)
#===============================================================================
ifeq ($(F90),$(filter $(F90),gfortran gfortran-8))

  # opt management
  ifeq ($(OOPT),1)
    FFLAGS = -O5 -g -fbacktrace -funroll-loops -ftree-vectorize -falign-loops=16
  else
    FFLAGS = -Og -g -fbacktrace -fcheck=all -fwhole-file -fcheck=pointer -Wuninitialized -finit-real=nan -finit-integer=nan
  endif

  # integer kind management
  ifeq ($(INT),8)
    FFLAGS += -fdefault-integer-8 -Dint8=1
  endif

  # omp management
  ifeq ($(OOMP),1)
    FFLAGS += -fopenmp
  endif
  FFLAGS0 := $(FFLAGS)


  # where to store the .mod files
  FFLAGS +=-J$(MOD_DIR)

  # where to look the .mod files
  FFLAGS += -I$(QDMOD_DIR)

  # some cpreprocessing
  FFLAGS += -cpp $(CPPSHELL)
  ifeq ($(OMP),1)
    FFLAGS += -Drun_openMP=1
  endif

  FLIB   = $(EXTLib)
  # OS management
  ifeq ($(LLAPACK),1)
    ifeq ($(OS),Darwin)    # OSX
      # OSX libs (included lapack+blas)
      FLIB += -framework Accelerate
    else                   # Linux
      # linux libs
      FLIB += -llapack -lblas
      #
      # linux libs with mkl and with openmp
      #FLIB = -L$(MKLROOT)/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_gnu_thread
      # linux libs with mkl and without openmp
      #FLIB = -L$(MKLROOT)/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential
    endif
  endif

  FC_VER = $(shell $(FFC) --version | head -1 )

endif
#=================================================================================

#===============================================================================
#===============================================================================
$(info ************************************************************************)
$(info ***********OS:               $(OS))
$(info ***********COMPILER:         $(FFC))
$(info ***********OPTIMIZATION:     $(OOPT))
$(info ***********COMPILER VERSION: $(FC_VER))
ifeq ($(FFC),mpifort)
$(info ***********COMPILED with:    $(MPICORE))
endif
$(info ***********OpenMP:           $(OOMP))
$(info ***********Lapack:           $(LLAPACK))
$(info ***********FFLAGS0:          $(FFLAGS0))
$(info ***********FLIB:             $(FLIB))
$(info ************************************************************************)
$(info ************************************************************************)

#==========================================
VPATH = SRC TESTS
#============================================================================
#Physical constants
PhysConst_SRCFILES = sub_module_RealWithUnit.f90 sub_module_Atom.f90 sub_module_constant.f90
PhysConstEXE       = PhysConst.exe
PhysConstMAIN      = PhysicalConstants_Main
#============================================================================
#============================================================================
#============================================================================

SRCFILES= $(PhysConst_SRCFILES) 

OBJ0=${SRCFILES:.f90=.o}
OBJ=$(addprefix $(OBJ_DIR)/, $(OBJ0))
$(info ************ OBJ: $(OBJ))
#
#============================================================================
# Physical Constants
.PHONY: PhysConst
PhysConst: $(PhysConstEXE)
	@echo "Physical Constants OK"
#
$(PhysConstEXE): $(LIBA) $(OBJ_DIR)/$(PhysConstMAIN).o
	$(FFC) $(FFLAGS) -o $(PhysConstEXE) $(OBJ_DIR)/$(PhysConstMAIN).o $(LIBA) $(FLIB)
#
.PHONY: ut UT UT_PhysConst ut_physconst
ut UT UT_PhysConst ut_physconst: $(PhysConstEXE)
	@echo "---------------------------------------"
	@echo "Unitary tests for the PhysConst module"
	cd TESTS ; (./run_tests &> Xres_UT_PhysConst ; ./PhysConst.sh Xres_UT_PhysConst)
	@echo "---------------------------------------"
#=============================================== res_UT_PhysConst
#===============================================
.PHONY: clean_UT
clean_UT:
	@cd TESTS ; ./clean
	@echo "TESTS are cleaned"
#===============================================
#============= Library: lib.....a  =============
#===============================================
.PHONY: lib
lib: $(LIBA)

$(LIBA): $(OBJ)
	ar -cr $(LIBA) $(OBJ)
	@echo "  done Library: "$(LIBA)
#
#===============================================
#============= compilation =====================
#===============================================
$(OBJ_DIR)/%.o: %.f90
	@echo "  compile: " $<
	$(FFC) $(FFLAGS) -o $@ -c $<
#===============================================
#================ cleaning =====================
.PHONY: clean cleanall
clean: clean_UT
	rm -f $(OBJ_DIR)/*/*.o $(OBJ_DIR)/*.o
	rm -f *.log TESTS/Xres_UT_PhysConst
	@echo "  done cleaning"

cleanall : clean clean_extlib
	rm -fr OBJ/obj* OBJ/*mod build
	rm -f lib*.a
	rm -f *.exe
	rm -f TESTS/res* TESTS/*log
	@echo "  done all cleaning"
#===============================================
#================ zip and copy the directory ===
ExtLibSAVEDIR := /Users/lauvergn/git/Ext_Lib
BaseName := ConstPhys
.PHONY: zip
zip: cleanall
	test -d $(ExtLibSAVEDIR) || (echo $(ExtLibDIR) "does not exist" ; exit 1)
	$(ExtLibSAVEDIR)/makezip.sh $(BaseName)
	cd $(ExtLibSAVEDIR) ; ./cp_ConstPhys.sh
	@echo "  done zip"
#===============================================
#=== external libraries ========================
# QDUtil
#===============================================
#
$(QDLIBA):
	@test -d $(ExtLibDIR) || (echo $(ExtLibDIR) "does not exist" ; exit 1)
	@test -d $(QD_DIR) || (cd $(ExtLibDIR) ; ./get_QDUtilLib.sh $(EXTLIB_TYPE))
	@test -d $(QD_DIR) || (echo $(QD_DIR) "does not exist" ; exit 1)
	cd $(QD_DIR) ; make lib FC=$(FFC) OPT=$(OOPT) OMP=$(OOMP) LAPACK=$(LLAPACK) ExtLibDIR=$(ExtLibDIR)
	@echo "  done " $(QDLIBA) " in "$(BaseName)
#
##
.PHONY: clean_extlib
clean_extlib:
	cd $(ExtLibDIR) ; ./cleanlib
#=======================================================================================
#=======================================================================================
#add dependencies
$(OBJ):                               $(EXTLib)

$(OBJ_DIR)/$(sub_module_Atom).o:      $(OBJ_DIR)/$(sub_module_RealWithUnit).o
$(OBJ_DIR)/$(sub_module_constant).o:  $(OBJ_DIR)/$(sub_module_Atom).o $(OBJ_DIR)/$(sub_module_RealWithUnit).o

$(OBJ_DIR)/$(PhysConstMAIN).o:        $(OBJ)

#=================================================================================
#=================================================================================
# ifort compillation v17 v18 with mkl
#=================================================================================
ifeq ($(FFC),ifort)

  # opt management
  ifeq ($(OOPT),1)
      #F90FLAGS = -O -parallel -g -traceback
      FFLAGS = -O  -g -traceback
  else
      FFLAGS = -O0 -check all -g -traceback
  endif

  # where to store the modules
  FFLAGS +=-module $(MOD_DIR)

  # omp management
  ifeq ($(OOMP),1)
    FFLAGS += -qopenmp
  endif

  # some cpreprocessing
  FFLAGS += -cpp $(CPPSHELL_QML)

  # where to look the .mod files
  FFLAGS += -I$(QDMOD_DIR)

  FLIB    = $(EXTLib)
  ifeq ($(LLAPACK),1)
    #FLIB += -mkl -lpthread
    #FLIB += -qmkl -lpthread
    FLIB +=  ${MKLROOT}/lib/libmkl_blas95_ilp64.a ${MKLROOT}/lib/libmkl_lapack95_ilp64.a ${MKLROOT}/lib/libmkl_intel_ilp64.a \
             ${MKLROOT}/lib/libmkl_intel_thread.a ${MKLROOT}/lib/libmkl_core.a -liomp5 -lpthread -lm -ldl
  else
    FLIB += -lpthread
  endif

  FC_VER = $(shell $(F90) --version | head -1 )

endif
#=================================================================================
#=================================================================================
