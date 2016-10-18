##########################################################
# 
# Copyright (c) 2004 Simon Southwell. All rights reserved.
#
# Date: 13th October 2004  
#
# Makefile for 'sparc_iss' instruction set simulator
# 
# $Id: makefile,v 1.6 2016-10-18 05:52:11 simon Exp $
# $Source: /home/simon/CVS/src/cpu/sparc/makefile,v $
# 
##########################################################

##########################################################
# Definitions
##########################################################

BASENAME=sparc
TARGET=${BASENAME}_iss
OBJECTS=${BASENAME}_iss.o execute.o inst.o read_write.o elf.o dis.o

LCOVINFO=sparc.info
COVLOGFILE=cov.log
COVDIR=cov_html
COVEXCL=dis.c sparc_iss.c

SRCDIR=src
OBJDIR=objs
TESTDIR=test

#ARCHOPT= -m32
ARCHOPT=

COVOPTS=-coverage

#CC=cc
#COPTS= -fast -xCC -I. -Isrc
CC=gcc
#COPTS=${ARCHOPT} -O3 -I. -Isrc
COPTS=${COVOPTS} -g -I. -Isrc

##########################################################
# Dependency definitions
##########################################################

all : ${TARGET}

${OBJDIR}/sparc_iss.o  : ${SRCDIR}/sparc_iss.c ${SRCDIR}/sparc_iss.h
${OBJDIR}/execute.o    : ${SRCDIR}/inst.h ${SRCDIR}/execute.c ${SRCDIR}/sparc.h ${SRCDIR}/sparc_iss.h
${OBJDIR}/inst.o       : ${SRCDIR}/sparc.h ${SRCDIR}/sparc_iss.h
${OBJDIR}/read_write.o : ${SRCDIR}/read_write.c ${SRCDIR}/sparc.h ${SRCDIR}/sparc_iss.h
${OBJDIR}/elf.o        : ${SRCDIR}/elf.c ${SRCDIR}/sparc.h ${SRCDIR}/elf.h ${SRCDIR}/sparc_iss.h
${OBJDIR}/dis.o        : ${SRCDIR}/dis.c ${SRCDIR}/sparc.h ${SRCDIR}/elf.h ${SRCDIR}/sparc_iss.h

##########################################################
# Compilation rules
##########################################################

${TARGET} : ${OBJECTS:%=${OBJDIR}/%}
	@$(CC) ${OBJECTS:%=${OBJDIR}/%} ${ARCHOPT} ${COVOPTS} -o ${TARGET}

${OBJDIR}/%.o : ${SRCDIR}/%.c
	@$(CC) $(COPTS) -c $< -o $@ 

##########################################################
# Microsoft Visual C++ 2010
##########################################################

MSVCDIR=./msvc
MSVCCONF="Release"

mscv_dummy:

MSVC:   mscv_dummy
	@MSBuild.exe ${MSVCDIR}/${BASENAME}.sln /nologo /v:q /p:Configuration=${MSVCCONF} /p:OutDir='..\..\'
	@rm *.pdb

##########################################################
# coverage
##########################################################

coverage:
	@lcov -c -d ${OBJDIR} -o ${LCOVINFO} > ${COVLOGFILE}
	@lcov -r ${LCOVINFO} ${COVEXCL} -o ${LCOVINFO} >> ${COVLOGFILE}
	@genhtml -o ${COVDIR} ${LCOVINFO} >> ${COVLOGFILE}

##########################################################
# Test
##########################################################

test: run_test
run_test: ${TARGET}
	@cd test; ./runtests

##########################################################
# Clean up rules
##########################################################

clean:
	@/bin/rm -f ${TARGET} ${OBJDIR}/*.o ${OBJDIR}/*.g* *.info ${TESTDIR}/*.o ${TESTDIR}/*.aout ${TESTDIR}/*.map ${TESTDIR}/*.sid

cleanmsvc:
	@/bin/rm -rf ${MSVCDIR}/*.sdf ${MSVCDIR}/*.suo ${MSVCDIR}/${BASENAME}/*.vcxproj.user ${MSVCDIR}/Debug ${MSVCDIR}/Release ${MSVCDIR}/ipch ${MSVCDIR}/${BASENAME}/Debug ${MSVCDIR}/${BASENAME}/Release

sparkle: clean cleanmsvc
	@rm -f *.exe *.log
