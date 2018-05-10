#include <xdc/std.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <xdc/runtime/System.h>
#include "HNR_C0_main.h"
#include "HNR_C0_platform_osal.h"
#include <ti/sysbios/knl/Task.h>
#include <ti/sysbios/knl/Queue.h>

#include "ti/platform/platform.h"

/* SRIO Driver Includes. */
#include <ti/drv/srio/srio_types.h>
#include <ti/drv/srio/include/listlib.h>
#include <ti/drv/srio/srio_drv.h>
#include "HNR_C0_SRIODriver.h"

#include "HNR_C0_GenFrame.h"
#include "HNR_C0_SoluFrame.h"
#include "HNR_C0_AD9361_command.h"
#include "HNR_C0_FPGA_Connector.h"
#include "HNR_C0_Task_AD9361.h"
#include "HNR_C0_Task_Networking.h"
#include "HNR_C0_UpdateUsersInfoTable.h"
#ifdef FIXEDPOINTDOAWEIGHTCAL
#include "DoaEstimatorCBFFixedPointImplement_fixpt.h"
#include "WeightCalcuMMSEFixedPointImplement_fixpt.h"
#include "FindOptiSyncFixedPointImplement_fixpt.h"
#else
#include "DoaEstimatorMUSICSignalImplement.h"
#include "DoaEstimatorCBFImplement.h"
#include "WeightCalcuMMSEImplement.h"
#include "FindOptiSyncImplement.h"
#endif
#include <recStvPartition.h>
#include "HNR_C0_Queun.h"


typedef struct cmdAttdef
{
	CMDIDELETYPE CmdIDEleType;
	int(* FuncPtr)();
}cmdAttdef;

cmdAttdef cmdIDTableEOut[NUMCMDIDOUT] = {
		{SETCARRFREQOUT,           SetCarrFreqOutCmdFrameHFunc},
		{SETTXPOWOUT,              SetTxPowOutCmdFrameHFunc},
		{SETADIRTXOUT,             SetADirTxOutCmdFrameHFunc},
		{SETBEAMRXOUT,             SetBeamRxOutCmdFrameHFunc},
		{SETBEAMTXOUT,             SetBeamTxOutCmdFrameHFunc},
		{QUEPHYUSERINFOOUT,        QuePhyUserInfoOutCmdFrameHFunc},
		{SETMACADDROUT,            SetMACAddrOutCmdFrameHFunc},
		{QUEPHYPEROUT,             QuePhyPEROutCmdFrameHFunc},
		{QUEPHYVEROUT,             QuePhyVerOutCmdFrameHFunc},
		{SETFIXRXBEAM1OUT,         SetFixRxBeam1OutCmdFrameHFunc},
		{SETFIXRXBEAM2OUT,         SetFixRxBeam2OutCmdFrameHFunc},
		{SETFIXRXBEAM3OUT,         SetFixRxBeam3OutCmdFrameHFunc},
		{SETADIRRXOUT,             SetADirRxOutCmdFrameHFunc},
		{STARTCALOUT,              StartCalOutCmdFrameHFunc},
		{SHAKEOUT,                 ShakeOutCmdFrameHFunc},
		{SETCSMAFIXRXBEAM1OUT,     SetCSMAFixRxBeam1OutCmdFrameHFunc},
		{SETCSMAFIXRXBEAM2OUT,     SetCSMAFixRxBeam2OutCmdFrameHFunc},
		{SETCSMAFIXRXBEAM3OUT,     SetCSMAFixRxBeam3OutCmdFrameHFunc},
		{SETCSMAFIXRXBEAM4OUT,     SetCSMAFixRxBeam4OutCmdFrameHFunc},
		{SETSLOTALLOCATEOUT,       SetSlotAllocateOutCmdFrameHFunc},
		{SETPPSOUT,                SetPPSOutCmdFrameHFunc},
		{ACCESSMODESELECTOUT,      AccessModeSelectOutCmdFrameHFunc},
		{STARTDOACALCUOUT,         StartDOACalcuOutCmdFrameHFunc},
		{HSSITESTOUT,              HSSITestOutCmdFrameHFunc},
		{SELECTTXSOURCEOUT,        SelectTxSourceOutCmdFrameHFunc}
};

cmdAttdef cmdIDTableEIn[NUMCMDIDIN] = {
		{CHANNELDETECTIN,          ChannelDetectInCmdFrameHFunc},
		{PHYINFOREPORTIN,          PhyInfoReportInCmdFrameHFunc},
		{READMACADDRIN,            ReadMACAddrInCmdFrameHFunc},
		{SETREPLYIN,               SetReplyInCmdFrameHFunc},
		{REPPHYPERIN,              RepPhyPERInCmdFrameHFunc},
		{REPPHYVERIN,              RepPhyVerInCmdFrameHFunc},
		{HSSITESTIN,               HSSITestInCmdFrameHFunc},
		{TESTDEBUGIN,              TestDebugInCmdFrameHFunc}
};

int SoluFrame()
{
	uint16_t idex = 0,idexCmdID = 0;

	for(idexCmdID = 0;idexCmdID < NUMCMDIDOUT;idexCmdID++)
	{
		for(idex = 0;idex < CMDIDLEN;idex++)
		{
			if(//pSrioCmdBuffer[CMDIDOFFSET + idex] != (cmdIDTableEOut[idexCmdID].CmdIDEleType >> ((CMDIDLEN - 1 - idex)*8) & 0xff)
				pSrioCmdBuffer[CMDIDOFFSET + idex] != (cmdIDTableEOut[idexCmdID].CmdIDEleType >> ((idex)*8) & 0xff))
			{
				break;
			}
		}
		if(idex == CMDIDLEN)
		{
			return cmdIDTableEOut[idexCmdID].FuncPtr();
		}
	}

	System_printf("Frame CmdID invalid.\n");
	char* debugString = "Error:Unsupported command type!";
	uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
	GenTestDebugInCmdFrame(debugString);
	dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
	return -1;
}

//extern uint16_t testGenShiftRegCRC[HSSITESTDATALEN - HSSITESTDATACRCLEN];
//uint16_t testSoluShiftRegCRC[HSSITESTDATALEN - HSSITESTDATACRCLEN] = {0};

int HSSITestOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint16_t shiftRegCRC = 0;

//	for(idex = 0;idex < HSSITESTFRAMELEN + HSSITESTFRAMENUMPADD0;idex++)
//	{
//		if(SrioTestBuff[idex] != pSrioCmdBuffer[idex])
//		{
//			break;
//		}
//	}

	for(idex = 0;idex < HSSITESTDATALEN - HSSITESTDATACRCLEN;idex++)
	{
		shiftRegCRC = tableCRC[(shiftRegCRC >> 8) ^ pSrioCmdBuffer[CMDPARAMOFFSET + idex]] ^ (shiftRegCRC << 8);
		//testSoluShiftRegCRC[idex] = shiftRegCRC;
	}

//	for(idex = 0;idex < HSSITESTDATALEN - HSSITESTDATACRCLEN;idex++)
//	{
//		if(testSoluShiftRegCRC[idex] != testGenShiftRegCRC[idex])
//		{
//			break;
//		}
//	}

	if(pSrioCmdBuffer[CMDPARAMOFFSET + idex++] == (shiftRegCRC >> 8 & 0xff) && pSrioCmdBuffer[CMDPARAMOFFSET + idex] == (shiftRegCRC & 0xff))
	{
		//System_printf("HSSITestOut Succeed.\n");
		return 0;
	}
	else
	{
//		for(idex = 0;idex < HSSITESTFRAMELEN + HSSITESTFRAMENUMPADD0;idex++)
//		{
//			if(SrioTestBuff[idex] != pSrioCmdBuffer[idex])
//			{
//				break;
//			}
//		}
		//System_printf("HSSITestOut Failed.\n");
		return -2;
	}
}

int SelectTxSourceOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t txSource = 0;
	double txSourceDouble = 0;
	double txSourceType = 0;
	for(idex = 0;idex < SELECTTXSOURCEDATALEN;idex++)
	{
		txSource = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (txSource << 8);
	}
	if(txSource > SELECTTXSOURCEMCS5)
	{
		System_printf("The parameter of transmit source selection is not valid.\n");
		char* debugString = "Error:The parameter of transmit source selection is not valid!";
		uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
		GenTestDebugInCmdFrame(debugString);
		dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
		return -1;
	}
//	if(txSource >= 0x02 && txSource <= 0x0a)//test signal need to take authority of switch
//	{
//		Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x1);
//	}
//	else
//	{
//		Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x0);
//	}
	//modify by Wayne for temporary power
//	double attTonemdB = INITIALATTAD9361TONE;
//	double attNormdB = INITIALATTAD9361NOR;
	if(txSource == 0x01)
	{
		Set624Att(INITIALATT624);

//		cmdExecuteToAD9361s(set_tx1_attenuation,&attTonemdB,1);
//		cmdExecuteToAD9361s(set_tx2_attenuation,&attTonemdB,1);
	}
	else
	{
		Set624Att(INITIALATT624QPSK);

//		cmdExecuteToAD9361s(set_tx1_attenuation,&attNormdB,1);
//		cmdExecuteToAD9361s(set_tx2_attenuation,&attNormdB,1);
	}
	switch(txSource)
	{
	case 0x00:
		txSourceType = 0x3333;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Normal business.\n");
		break;
	case 0x01:
		txSourceType = 0x1111;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:FPGA NCO.\n");
		break;
	case 0x02:
		txSourceDouble = 6;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Pure QPSK.\n");
		break;
	case 0x03:
		txSourceDouble = 7;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Pure 16QAM.\n");
		break;
	case 0x04:
		txSourceDouble = 8;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Pure 64QAM.\n");
		break;
	case 0x05:
		txSourceDouble = 0;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS0.\n");
		break;
	case 0x06:
		txSourceDouble = 1;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS1.\n");
		break;
	case 0x07:
		txSourceDouble = 2;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS2.\n");
		break;
	case 0x08:
		txSourceDouble = 3;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS3.\n");
		break;
	case 0x09:
		txSourceDouble = 4;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS4.\n");
		break;
	case 0x0a:
		txSourceDouble = 5;//according to implementation of set_test_signal_type
		set_test_signal_type(&txSourceDouble, 1);
		txSourceType = 0x6666;
		set_tx_source(&txSourceType, 1);
		System_printf("Transmit source:Test MCS5.\n");
		break;
	default:
		break;
	}
	return 0;
}

double carrFreqCurr = DEFAULTFREQ;
int SetCarrFreqOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint16_t carrFreq = 0;
	static int32_t ret1 = 0, ret2 = 0;
	static double carrFreqD = DEFAULTFREQ;
	for(idex = 0;idex < SETCARRFREQDATALEN;idex++)
	{
		//carrFreq = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (carrFreq << 8);
		//modify for 206 by Wayne
		carrFreq = ((pSrioCmdBuffer[CMDPARAMOFFSET + idex]) << (idex*8)) + (carrFreq);
	}
	if(carrFreq < 5625 || carrFreq > 5825)
	{
		System_printf("The parameter of carrier frequency is not valid.\n");
		char* debugString = "Error:Carrier frequency should be among 5625~5825MHz!";
		uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
		GenTestDebugInCmdFrame(debugString);
		dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
		return -1;
	}

	//Temporary selection to release hand shake pressure.
	if(!(carrFreqD == carrFreq && ret1 == 0 && ret2 == 0))
	{
		carrFreqD = carrFreq;
		//set_tx_lo_freq(&carrFreqD, 1);
		uint16_t resultPRBSTest = 0;
		while((resultPRBSTest & 0x00ff) != 0x00ff)
		{
			ret1 = cmdExecuteToAD9361s(set_tx_lo_freq,&carrFreqD, 1);
			ret2 = cmdExecuteToAD9361s(set_rx_lo_freq,&carrFreqD, 1);

			AD9361MCS();

			resultPRBSTest = FPGAAD9361SinglePRBSTest();
		}

		for(idex = 0;idex < TOTALSTVLEN;idex++)
		{
			recStvPartition[idex].re = recStvPartitionI[carrFreq - FREQSTART][idex];
			recStvPartition[idex].im = recStvPartitionQ[carrFreq - FREQSTART][idex];
		}
	}

//	carrFreqD = carrFreq;
//	//set_tx_lo_freq(&carrFreqD, 1);
//	ret1 = cmdExecuteToAD9361s(set_tx_lo_freq,&carrFreqD, 1);
//	ret2 = cmdExecuteToAD9361s(set_rx_lo_freq,&carrFreqD, 1);
	if(ret1 == 0 && ret2 == 0)
	{
		GenSetReplyInCmdFrame(SETREPLYSETFREQS);
		dioSocketsSend((SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0 + 255)/256, SrioSendBuff, SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0);

//		//waste operation
//		//delay for grab precise FPGA status
//		platform_delay(10);
//		if(Read_FPGA_Reg(FPGA_REG_SRIO_STAT) || Read_FPGA_Reg(FPGA_REG_SERDES_STAT))
//		{
//			if(Read_FPGA_Reg(FPGA_REG_SRIO_STAT))
//			{
//				Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x1);
//				Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x0);
//				platform_delay(1000);
//				Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x1);
//				System_printf("reset srio\n");
//			}
//			if(Read_FPGA_Reg(FPGA_REG_SERDES_STAT))
//			{
//				Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x1);
//				Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x0);
//				platform_delay(1000);
//				Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x1);
//				System_printf("reset serdes\n");
//			}
//		}
//		else
//		{
//			if(!readyFlag)
//			{
//				Write_FPGA_Reg(FPGA_REG_RF_TR, 0x0699);
//				Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x0);//FPGA control
//				readyFlag = 1;
//
//				platform_gpio_test(3, PLATFORM_GPIO_RST);
//				platform_delay(200000);//delay 200ms
//				platform_gpio_test(3, PLATFORM_GPIO_SET);
//			}
//		}

	}
	else
	{
		GenSetReplyInCmdFrame(SETREPLYSETFREQF);
		dioSocketsSend((SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0 + 255)/256, SrioSendBuff, SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0);
	}

	carrFreqCurr = carrFreqD;

	return 0;
}

int SetTxPowOutCmdFrameHFunc()
{
	uint16_t idex = 0;
//	uint16_t idexB = 0;
	int8_t txPower = 0;
//	uint8_t userID[6] = {0};
//	uint16_t tempOffsetAddr = 0;
	for(idex = 0;idex < SETTXPOWPARAM1LEN;idex++)
	{
		txPower = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (txPower << 8);
	}
	if(txPower < 0 || txPower > 56)
	{
		System_printf("The parameter of TX power is not valid.\n");
		char* debugString = "Error:Transmit power should be among 0~28dBm!";
		uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
		GenTestDebugInCmdFrame(debugString);
		dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
		return -1;
	}
	//temporary implementation for test according to exited FPGA code
	Write_FPGA_Reg(FPGA_REG_RF_ATT, (uint16_t)(63 - (28 - (double)txPower/2 + INITIALATT624QPSK)*2));
	uint32_t idxSectorAtt = 0;
	for(idxSectorAtt = FPGA_REG_SECTOR_1_ATT;idxSectorAtt <= FPGA_REG_SECTOR_24_ATT;idxSectorAtt++)
	{
		Write_FPGA_Reg(idxSectorAtt, (uint16_t)(63 - (28 - (double)txPower/2 + INITIALATT624QPSK)*2));
	}
	if(Read_FPGA_Reg(FPGA_REG_SECTOR_1_ATT) == (uint16_t)(63 - (28 - (double)txPower/2 + INITIALATT624QPSK)*2))
	{
		System_printf("Transmit power:%ddBm.\n",txPower/2);
		GenSetReplyInCmdFrame(SETREPLYSETTXPOWERS);
		dioSocketsSend((SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0 + 255)/256, SrioSendBuff, SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0);
	}
	else
	{
		System_printf("Transmit power:Set failed.\n");
		GenSetReplyInCmdFrame(SETREPLYSETTXPOWERF);
		dioSocketsSend((SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0 + 255)/256, SrioSendBuff, SETREPLYFRAMELEN + SETREPLYFRAMENUMPADD0);
	}
	return 0;
//fix warning by wayne
//	for(idex = 0;idex < SETTXPOWPARAM2LEN;idex++)
//	{
//		userID[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + SETTXPOWPARAM1LEN + idex];
//	}
//	for(idex = 0;idex < NUMUSERS;idex++)
//	{
//		for(idexB = 0;idexB < 6;idexB++)
//		{
//			switch(idexB)
//			{
//			case 0:
//			case 1:
//				tempOffsetAddr = FPGA_REG_USER_INFO_ID_L_OFFSETADDR;
//				break;
//			case 2:
//			case 3:
//				tempOffsetAddr = FPGA_REG_USER_INFO_ID_M_OFFSETADDR;
//				break;
//			case 4:
//			case 5:
//				tempOffsetAddr = FPGA_REG_USER_INFO_ID_H_OFFSETADDR;
//				break;
//			default:
//				break;
//			}
//			if((Read_FPGA_Reg(FPGA_REG_BROADCAST_BASEADDR + idex*FPGA_REG_USER_BASEADDR_INTERVAL + tempOffsetAddr) >> (idexB % 2?0:8) & 0xff) != userID[idexB])
//			{
//				break;
//			}
//
//		}
//		if(idexB == 6)
//		{
//			Write_FPGA_Reg(FPGA_REG_BROADCAST_BASEADDR + idex*FPGA_REG_USER_BASEADDR_INTERVAL + FPGA_REG_USER_INFO_TX_POWER_OFFSETADDR, txPower);
//			return 0;
//		}
//	}
//	//System_printf("Can not find this user ID in info table.\n");
//	return -1;
}


int SetADirRxOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t sector = 0;
	uint8_t weightBS[SETADIRTXPARAM2LEN] = {0};
	uint8_t readbackBS[SETADIRTXPARAM2LEN] = {0};
	uint8_t errFlag = 1;

	for(idex = 0;idex < SETADIRRXPARAM1LEN;idex++)
	{
		sector = (pSrioCmdBuffer[CMDPARAMOFFSET + idex] << (idex << 3)) + sector;
	}
	Write_FPGA_Reg(FPGA_REG_RF_SECT_DISC, 0x000 + (sector & 0x1f));//AB coupling

	while(errFlag)
	{
		for(idex = 0;idex < SETADIRRXPARAM2LEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + SETADIRRXPARAM1LEN + idex];
		}
		for(idex = 0;idex < SETADIRRXPARAM2LEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETADIRRXPARAM2LEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETADIRRXPARAM2LEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}

	//Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x1);//DSP control//determined by source selection

	return 0;
}

int SetBeamRxOutCmdFrameHFunc(){return 0;}
int SetADirTxOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t sector = 0;
	uint8_t weightBS[SETADIRTXPARAM2LEN] = {0};
	uint8_t readbackBS[SETADIRTXPARAM2LEN] = {0};
	uint8_t errFlag = 1;

	for(idex = 0;idex < SETADIRTXPARAM1LEN;idex++)
	{
		sector = (pSrioCmdBuffer[CMDPARAMOFFSET + idex] << (idex << 3)) + sector;
	}
	Write_FPGA_Reg(FPGA_REG_RF_SECT_DISC, 0x200 + (sector & 0x1f));//AB coupling

	while(errFlag)
	{
		for(idex = 0;idex < SETADIRTXPARAM2LEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + SETADIRTXPARAM1LEN + idex];
		}
		for(idex = 0;idex < SETADIRTXPARAM2LEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETADIRTXPARAM2LEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETADIRTXPARAM2LEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}

//	//temporary configure fixed transmission weight
//	uint16_t zeroDegreeTxWeight[8] = {8421,31666,32767,0,32767,0,8421,31666};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, zeroDegreeTxWeight[idex]);
//	}
//
//	//{-28066,25863,32767,25863},{-16910,-20118,0,-20118},
//	int16_t sevenpointfiveDegreeTxWeight[8] = {-28066,16910,25863,20118,32767,0,25863,20118};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, (uint16_t)sevenpointfiveDegreeTxWeight[idex]);
//	}
//
//	//{-25025,8421,32767,32767},{21151,-31666,0,0},
//	int16_t fifteenDegreeTxWeight[8] = {-25025,-21151,8421,31666,32767,0,32767,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, (uint16_t)fifteenDegreeTxWeight[idex]);
//	}
//
//	//{1990,-12412,30985,32767},{32706,-30325,-10656,0},
//	int16_t eighteenpointsevenfiveDegreeTxWeight[8] = {1990,-32706,-12412,30325,30985,10656,32767,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, (uint16_t)eighteenpointsevenfiveDegreeTxWeight[idex]);
//	}
//
//	//{29385,-32041,16217,32767},{-14496,6857,-28472,0},
//	int16_t twentysevenDegreeTxWeight[8] = {29385,14496,-32041,-6857,16217,28472,32767,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, (uint16_t)twentysevenDegreeTxWeight[idex]);
//	}
//
//	uint16_t AChannelTxWeight[8] = {0x7fff,0,0,0,0,0,0,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, AChannelTxWeight[idex]);
//	}
//
//	uint16_t BChannelTxWeight[8] = {0,0,0x7fff,0,0,0,0,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, BChannelTxWeight[idex]);
//	}
//
//	uint16_t CChannelTxWeight[8] = {0,0,0,0,0x7fff,0,0,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, CChannelTxWeight[idex]);
//	}
//
//	uint16_t DChannelTxWeight[8] = {0,0,0,0,0,0,0x7fff,0};
//	for(idex = 0;idex < 8;idex++)
//	{
//		Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex, DChannelTxWeight[idex]);
//	}

	Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x1);//DSP control//determined by source selection

	return 0;
}
int SetBeamTxOutCmdFrameHFunc(){return 0;}


int QuePhyUserInfoOutCmdFrameHFunc()
{
	uint16_t userIDReport[NUMDOUBLEWORDUSERID] = {0};

	//use stream operation to instead of assignment byte by byte, for convenience
	memcpy((void*)userIDReport, (const void*)(&pSrioCmdBuffer[CMDPARAMOFFSET]), NUMDOUBLEWORDUSERID*sizeof(uint16_t));

	GenPhyInfoReportInCmdFrame(userIDReport);
	//GenTestPhyInfoReportInCmdFrame();

	return 0;
}

uint8_t outdoorMACAddrArry[6] = {0};
int SetMACAddrOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	for(idex = 0;idex < SETMACADDRDATALEN;idex++)
	{
		outdoorMACAddrArry[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
	}
	return 0;
}

int QuePhyPEROutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t flagPER = 0;
	for(idex = 0;idex < QUEPHYPERDATALEN;idex++)
	{
		flagPER = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (flagPER << 8);
	}
	if(flagPER == 0)
	{
		GenRepPhyPERInCmdFrame();
	}
	else
	{
		Write_FPGA_Reg(FPGA_REG_PKG_STTT_EN, 0);
		Write_FPGA_Reg(FPGA_REG_PKG_STTT_EN, 1);
	}

	//Temporary test
	//System_printf("PER Report\n");

	return 0;
}

int QuePhyVerOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t flagVer = 0;
	for(idex = 0;idex < QUEPHYVERDATALEN;idex++)
	{
		//have hidden trouble, temporary do not modify
		flagVer = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (flagVer << 8);
	}
	if(flagVer != 0x01 && flagVer != 0x02)
	{
		System_printf("The parameter of version query is invalid!\n");
		char* debugString = "The parameter of version query is invalid!";
		uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
		GenTestDebugInCmdFrame(debugString);
		dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
		return -1;
	}
	else
	{
		GenRepPhyVerInCmdFrame(flagVer);
	}
	return 0;
}

uint16_t numUserInfoRecv = 0;
int PhyInfoReportInCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint16_t mutiUserFrameLen = 0;
	numUserInfoRecv = 0;
	for(idex = 0;idex < FRAMELENLEN;idex++)
	{
		mutiUserFrameLen = pSrioCmdBuffer[FRAMELENOFFSET + idex] + (mutiUserFrameLen << 8);
	}
	numUserInfoRecv = (mutiUserFrameLen - CMDPARAMOFFSET)/PHYINFOREPORTSDATALEN;
	for(idex = 0;idex < numUserInfoRecv;idex++)
	{
		//phyUserInfoTable[idex] = *(phyUserInfo*)(&pSrioCmdBuffer[CMDPARAMOFFSET + idex*PHYINFOREPORTSDATALEN]);
	}
	return 0;
}

int ReadMACAddrInCmdFrameHFunc()
{
	uint16_t idex = 0;
	for(idex = 0;idex < READMACADDRDATALEN;idex++)
	{
		if(indoorMACAddrArry[idex] != pSrioCmdBuffer[CMDPARAMOFFSET + idex])
		{
			break;
		}
	}
	if(idex == READMACADDRDATALEN)
	{
		//System_printf("Succeed to set MAC address of outdoor.\n");
		return 0;
	}
	else
	{
		//System_printf("Set MAC address of outdoor failed.\n");
		return -1;
	}
}



int HSSITestInCmdFrameHFunc()
{
	uint16_t idex = 0,shiftRegCRC = 0;
	for(idex = 0;idex < HSSITESTDATALEN - HSSITESTDATACRCLEN;idex++)
	{
		shiftRegCRC = tableCRC[(shiftRegCRC >> 8) ^ pSrioCmdBuffer[CMDPARAMOFFSET + idex]] ^ (shiftRegCRC << 8);
	}
	if(pSrioCmdBuffer[CMDPARAMOFFSET + idex++] == (shiftRegCRC >> 8 & 0xff) && pSrioCmdBuffer[CMDPARAMOFFSET + idex] == (shiftRegCRC & 0xff))
	{
		//System_printf("HSSITestOut Succeed.\n");
		return 0;
	}
	else
	{
		//System_printf("HSSITestOut Failed.\n");
		return -1;
	}
}

uint8_t  channelDetectStatus = 1;
uint8_t  channelDetectSector = 24;
uint32_t channelDetectNoiseNP = 0;
int ChannelDetectInCmdFrameHFunc()
{
	uint16_t idex = 0;
	channelDetectStatus = 0;
	for(idex = 0;idex < CHANNELDETECTPARAM1LEN;idex++)
	{
		channelDetectStatus = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (channelDetectStatus << 8);
	}
	channelDetectSector = 0;
	for(idex = 0;idex < CHANNELDETECTPARAM2LEN;idex++)
	{
		channelDetectSector = pSrioCmdBuffer[CMDPARAMOFFSET + CHANNELDETECTPARAM1LEN + idex] + (channelDetectSector << 8);
	}
	channelDetectNoiseNP = 0;
	for(idex = 0;idex < CHANNELDETECTPARAM3LEN;idex++)
	{
		channelDetectNoiseNP = pSrioCmdBuffer[CMDPARAMOFFSET + CHANNELDETECTPARAM1LEN+ CHANNELDETECTPARAM2LEN + idex] + (channelDetectNoiseNP << 8);
	}
	return 0;
}

uint8_t setReplyVal = 0;
int SetReplyInCmdFrameHFunc()
{
	uint16_t idex = 0;
	channelDetectStatus = 0;
	for(idex = 0;idex < SETREPLYDATALEN;idex++)
	{
		setReplyVal = pSrioCmdBuffer[CMDPARAMOFFSET + idex] + (setReplyVal << 8);
	}
	return 0;
}

int RepPhyPERInCmdFrameHFunc()
{
	return 0;
}

int RepPhyVerInCmdFrameHFunc()
{
	return 0;
}

int TestDebugInCmdFrameHFunc()
{
	return 0;
}

//for temporary debug
int GenTestChannelDetectInCmdFrame()
{
	uint16_t idex = 0;
	for(idex = 0;idex < FRAMETYPELEN;idex++)
	{
		SrioSendBuff[FRAMETYPEOFFSET + idex] = CMDFRAMETYPE >> ((FRAMETYPELEN - 1 - idex)*8);
	}
	for(idex = 0;idex < FRAMELENLEN;idex++)
	{
		//SrioSendBuff[FRAMELENOFFSET + idex] = CHANNELDETECTFRAMELEN >> ((FRAMELENLEN - 1 - idex)*8);
		SrioSendBuff[FRAMELENOFFSET + idex] = CHANNELDETECTFRAMELEN >> (idex*8);
	}
	for(idex = 0;idex < CMDIDLEN;idex++)
	{
		//SrioSendBuff[CMDIDOFFSET + idex] = CHANNELDETECTIN >> ((CMDIDLEN - 1 - idex)*8);
		//modify for 206 by Wayne
		SrioSendBuff[CMDIDOFFSET + idex] = CHANNELDETECTIN >> ((idex)*8);
	}
	for(idex = 0;idex < CHANNELDETECTPARAM1LEN;idex++)
	{
		SrioSendBuff[CMDPARAMOFFSET + idex] = 0;
	}
	for(idex = 0;idex < CHANNELDETECTPARAM2LEN;idex++)
	{
		SrioSendBuff[CMDPARAMOFFSET + CHANNELDETECTPARAM1LEN + idex] = 24;
	}
	for(idex = 0;idex < CHANNELDETECTPARAM3LEN;idex++)
	{
		SrioSendBuff[CMDPARAMOFFSET + CHANNELDETECTPARAM1LEN+ CHANNELDETECTPARAM2LEN + idex] = 0;
	}
	for(idex = 0;idex < CHANNELDETECTFRAMENUMPADD0;idex++)
	{
		SrioSendBuff[CHANNELDETECTFRAMELEN + idex] = 0;
	}
	//Osal_WritebackCache((void*)SrioSendBuff, (64 - ((CHANNELDETECTFRAMELEN + CHANNELDETECTFRAMENUMPADD0) % 64)) % 64 + (CHANNELDETECTFRAMELEN + CHANNELDETECTFRAMENUMPADD0));
	dioSocketsSend((CHANNELDETECTFRAMELEN + CHANNELDETECTFRAMENUMPADD0 + 255)/256, SrioSendBuff, CHANNELDETECTFRAMELEN + CHANNELDETECTFRAMENUMPADD0);
	return 0;
}


int GenTestPhyInfoReportInCmdFrame()
{
	uint16_t idex = 0,idexB = 0;
	uint16_t numUserReport = 0;
	uint16_t mutiUserFrameLen = 0,numMutiUserPadd0 = 0;
	uint32_t numReportUsers = 5;

	for(idex = 0;idex < FRAMETYPELEN;idex++)
	{
		SrioSendBuff[FRAMETYPEOFFSET + idex] = CMDFRAMETYPE >> ((FRAMETYPELEN - 1 - idex)*8);
	}
	for(idex = 0;idex < numReportUsers;idex++)
	{
		for(idexB = 0;idexB < NUMDOUBLEWORDUSERID;idexB++)
		{
			if(idex == 0)
			{
				userInfoTable[numUserReport].UserID[idexB] = 0xffff;
			}
			else
			{
				userInfoTable[numUserReport].UserID[idexB] = ((idex*4 + idexB*2 + 0xf) << 8) + 0xf;
			}
		}
		userInfoTable[numUserReport].TxMCSTxPower = (0 << 8) | ((28*2 - 2*idex) & 0xff);
		userInfoTable[numUserReport].SectorRxMCS = ((24 - 6*idex) << 8) | (0 & 0xff);
		userInfoTable[numUserReport].Angle = idex*6000;
		for(idexB = 0;idexB < NUMRXWEIGHT;idexB++)
		{
			userInfoTable[numUserReport].RxWeight[idexB] = idex + idexB + 1;
		}
		userInfoTable[numUserReport].DistanceL = idex*20000 + 10;
		userInfoTable[numUserReport].DistanceH = (idex*20000 + 10) >> 16;
		userInfoTable[numUserReport].RxSNR = idex*4000 - 10000;
		userInfoTable[numUserReport].RSSI = idex*4000 - 10000;
		userInfoTable[numUserReport].UpdateEffect = idex;
		numUserReport++;

	}
	for(idex = 0;idex < CMDIDLEN;idex++)
	{
		//SrioSendBuff[CMDIDOFFSET + idex] = PHYINFOREPORTIN >> ((CMDIDLEN - 1 - idex)*8);
		//modify for 206 by Wayne
		SrioSendBuff[CMDIDOFFSET + idex] = PHYINFOREPORTIN >> ((idex)*8);

	}
	mutiUserFrameLen = CMDPARAMOFFSET + PHYINFOREPORTSDATALEN*numUserReport;
	for(idex = 0;idex < FRAMELENLEN;idex++)
	{
		//SrioSendBuff[FRAMELENOFFSET + idex] = mutiUserFrameLen >> ((FRAMELENLEN - 1 - idex)*8);
		SrioSendBuff[FRAMELENOFFSET + idex] = mutiUserFrameLen >> (idex*8);
	}
	for(idex = 0;idex < numUserReport;idex++)
	{
		//consideration of data type align, use stream operation
		memcpy((void*)(&(SrioSendBuff[CMDPARAMOFFSET + idex*PHYINFOREPORTSDATALEN])), (const void*)(&userInfoTable[idex]), PHYINFOREPORTSDATALEN);
	}
	numMutiUserPadd0 = (8 - (mutiUserFrameLen % 8)) % 8;
	for(idex = 0;idex < numMutiUserPadd0;idex++)
	{
		SrioSendBuff[mutiUserFrameLen + idex] = 0;
	}
	//Osal_WritebackCache((void*)SrioSendBuff, (64 - ((mutiUserFrameLen + numMutiUserPadd0) % 64)) % 64 + (mutiUserFrameLen + numMutiUserPadd0));
	dioSocketsSend((mutiUserFrameLen + numMutiUserPadd0 + 255)/256, SrioSendBuff, mutiUserFrameLen + numMutiUserPadd0);
	return 0;
}

int SetFixRxBeam1OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETFIXRXBEAM1DATALEN] = {0};
	uint8_t readbackBS[SETFIXRXBEAM1DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_FIX_BF1_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_FIX_BF1_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("1 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int SetFixRxBeam2OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETFIXRXBEAM2DATALEN] = {0};
	uint8_t readbackBS[SETFIXRXBEAM2DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETFIXRXBEAM2DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETFIXRXBEAM2DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_FIX_BF2_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETFIXRXBEAM2DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_FIX_BF2_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETFIXRXBEAM2DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("2 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int SetFixRxBeam3OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETFIXRXBEAM3DATALEN] = {0};
	uint8_t readbackBS[SETFIXRXBEAM3DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETFIXRXBEAM3DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETFIXRXBEAM3DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_FIX_BF3_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETFIXRXBEAM3DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_FIX_BF3_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETFIXRXBEAM3DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("3 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETFIXRXBEAM1DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int StartCalOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t calParam = 0;
	double txCarrFreq = DEFAULTFREQ;
	double rxCarrFreq = DEFAULTFREQ;

	FPGA_Reg_Init();
	FPGARegConfig();

	for(idex = 0;idex < STARTCALDATALEN;idex++)
	{
		calParam = ((pSrioCmdBuffer[CMDPARAMOFFSET + idex]) << (idex << 3)) + calParam;
	}

	uint16_t pre624Att = Read624Att();

	channelCalFlag = 1;

	Set624Att(INITIALATT624QPSK);
	SetRxMGCAuthorityPackage(1);//DSP control
	if(calParam == 0x00)
	{
		txCarrFreq = carrFreqCurr;
		rxCarrFreq = carrFreqCurr - DELTAFC;
		SetAD9364CarrFreq(&txCarrFreq, &rxCarrFreq);
		if(RX_channel_selftest())//ad9361_receive_calibration();
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) | (0x01 << 8));
			channelCalFlag = 0;
			//GenRepCalResultInCmdFrame(REPCALRESULTRXF);
			GenRepCalResultInCmdFrame(REPCALRESULTRXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("receive self test fail!!!\n\n");
		}
		else
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) & (~(0x01 << 8)));
			channelCalFlag = 0;
			GenRepCalResultInCmdFrame(REPCALRESULTRXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("receive self test succeed\n\n");
		}
	}
	else if(calParam == 0x10)
	{
		txCarrFreq = carrFreqCurr - DELTAFC;
		rxCarrFreq = carrFreqCurr;
		SetAD9364CarrFreq(&txCarrFreq, &rxCarrFreq);
		if(TX_channel_selftest(0x1000))//ad9361_transmit_calibration(0x1000);//3.125MHZ;
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) | (0x01));
			channelCalFlag = 0;
			//GenRepCalResultInCmdFrame(REPCALRESULTTXF);
			GenRepCalResultInCmdFrame(REPCALRESULTTXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("transmit self test fail!!!\n\n");
		}
		else
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) & (~(0x01)));
			channelCalFlag = 0;
			GenRepCalResultInCmdFrame(REPCALRESULTTXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("transmit self test succeed\n\n");
		}
	}
	else if(calParam == 0x20)
	{
		txCarrFreq = carrFreqCurr;
		rxCarrFreq = carrFreqCurr - DELTAFC;
		SetAD9364CarrFreq(&txCarrFreq, &rxCarrFreq);
		if(RX_channel_selftest())//ad9361_receive_calibration();
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) | (0x01 << 8));
			//GenRepCalResultInCmdFrame(REPCALRESULTRXF);
			GenRepCalResultInCmdFrame(REPCALRESULTRXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("receive self test fail!!!\n\n");
		}
		else
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) & (~(0x01 << 8)));
			GenRepCalResultInCmdFrame(REPCALRESULTRXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("receive self test succeed\n\n");
		}
		platform_delay(10000);
		txCarrFreq = carrFreqCurr - DELTAFC;
		rxCarrFreq = carrFreqCurr;
		SetAD9364CarrFreq(&txCarrFreq, &rxCarrFreq);
		if(TX_channel_selftest(0x1000))//ad9361_transmit_calibration(0x1000);//3.125MHZ;
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) | (0x01));
			channelCalFlag = 0;
			//GenRepCalResultInCmdFrame(REPCALRESULTTXF);
			GenRepCalResultInCmdFrame(REPCALRESULTTXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("transmit self test fail!!!\n\n");
		}
		else
		{
			Write_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO, Read_FPGA_Reg(FPGA_REG_CHANNELS_CAL_INFO) & (~(0x01)));
			channelCalFlag = 0;
			GenRepCalResultInCmdFrame(REPCALRESULTTXS);
			dioSocketsSend((REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0 + 255)/256, SrioSendBuff, REPCALRESULTFRAMELEN + REPCALRESULTFRAMENUMPADD0);
			System_printf("transmit self test succeed\n\n");
		}
	}
	else if(calParam == 0x30)
	{
		channelCalFlag = 0;
		System_printf("IQ calibration have not been implemented!!!\n\n");
	}
	else
	{
		System_printf("The parameter of start calibration is invalid!\n");
		char* debugString = "The parameter of start calibration is invalid!";
		uint16_t debugFrameLen = CMDPARAMOFFSET + strlen(debugString) + 1;
		channelCalFlag = 0;
		GenTestDebugInCmdFrame(debugString);
		dioSocketsSend((debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)) + 255)/256, SrioSendBuff, debugFrameLen + (((8) - ((debugFrameLen) % (8))) % (8)));
		return -1;
	}

	FPGARegConfig();
	Set624Att(pre624Att);
	Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x0);//FPGA control
	SetRxMGCAuthorityPackage(0);//FPGA control

	return 0;
}

int SetCSMAFixRxBeam1OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETCSMAFIXRXBEAM1DATALEN] = {0};
	uint8_t readbackBS[SETCSMAFIXRXBEAM1DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETCSMAFIXRXBEAM1DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM1DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_CSMA_FIX_BF1_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM1DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_CSMA_FIX_BF1_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETCSMAFIXRXBEAM1DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("CSMA 1 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETCSMAFIXRXBEAM1DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int SetCSMAFixRxBeam2OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETCSMAFIXRXBEAM2DATALEN] = {0};
	uint8_t readbackBS[SETCSMAFIXRXBEAM2DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETCSMAFIXRXBEAM2DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM2DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_CSMA_FIX_BF2_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM2DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_CSMA_FIX_BF2_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETCSMAFIXRXBEAM2DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("CSMA 2 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETCSMAFIXRXBEAM2DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int SetCSMAFixRxBeam3OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETCSMAFIXRXBEAM3DATALEN] = {0};
	uint8_t readbackBS[SETCSMAFIXRXBEAM3DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETCSMAFIXRXBEAM3DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM3DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_CSMA_FIX_BF3_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM3DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_CSMA_FIX_BF3_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETCSMAFIXRXBEAM3DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("CSMA 3 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETCSMAFIXRXBEAM3DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

int SetCSMAFixRxBeam4OutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t weightBS[SETCSMAFIXRXBEAM4DATALEN] = {0};
	uint8_t readbackBS[SETCSMAFIXRXBEAM4DATALEN] = {0};
	uint8_t errFlag = 1;

	while(errFlag)
	{
		for(idex = 0;idex < SETCSMAFIXRXBEAM4DATALEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM4DATALEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_CSMA_FIX_BF4_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		for(idex = 0;idex < SETCSMAFIXRXBEAM4DATALEN;idex += 2)
		{
			*((uint16_t*)&(readbackBS[idex])) = Read_FPGA_Reg(FPGA_REG_CSMA_FIX_BF4_1CH_I + idex/2);
		}
		errFlag = 0;
		for(idex = 0;idex < SETCSMAFIXRXBEAM4DATALEN;idex++)
		{
			if(weightBS[idex] != readbackBS[idex])
			{
				errFlag = 1;
				break;
			}
		}
	}
	System_printf("CSMA 4 Fixed Rx Beamform Weights Configure success!\n");

	//Temporary test
	for(idex = 0;idex < SETCSMAFIXRXBEAM4DATALEN;idex++)
	{
		System_printf("%02x",weightBS[idex]);
	}
	System_printf("\n");

	return 0;
}

//Temporary test
uint32_t FrameIDFilter = 50;
uint32_t FrameIDPre = 0;
uint32_t FrameIDPreFlag = 0;
uint8_t FrameID_dug[2];
uint32_t FrameIDPreError = 0;

int SetSlotAllocateOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint16_t idexSlot = 0;
	uint8_t weightBS[SETSLOTALLOCATEPARAM4LEN] = {0};
	uint8_t RTxIndicate = 0;
	uint16_t timeOffset = 0;
	uint8_t sector = 0;
	uint8_t frameID = 0;

	frameID = pSrioCmdBuffer[CMDPARAMOFFSET + SETSLOTALLOCATEELEMENTLEN*SETSLOTALLOCATEPARAMNUM];

	//Temporary test
	if(!(frameID == FrameIDPre + 1 || (frameID == FrameIDPre - 39 && frameID == 0)) && FrameIDPreFlag)
	{
//		System_printf("Error: PreFrameID %d,FrameID %d!\n", FrameIDPre, frameID);
		FrameID_dug[0] = FrameIDPre;
		FrameID_dug[1] = frameID;
		FrameIDPreError++;
	}
	FrameIDPre = frameID;
	FrameIDPreFlag = 1;

	for(idexSlot = 0;idexSlot < SETSLOTALLOCATEPARAMNUM;idexSlot++)
	{
		RTxIndicate = 0;
		timeOffset = 0;
		sector = 0;
		for(idex = 0;idex < SETSLOTALLOCATEPARAM1LEN;idex++)
		{
			RTxIndicate = ((pSrioCmdBuffer[CMDPARAMOFFSET + SETSLOTALLOCATEELEMENTLEN*idexSlot + idex]) << (idex << 3)) + RTxIndicate;
		}
		for(idex = 0;idex < SETSLOTALLOCATEPARAM2LEN;idex++)
		{
			timeOffset = ((pSrioCmdBuffer[CMDPARAMOFFSET + SETSLOTALLOCATEELEMENTLEN*idexSlot + SETSLOTALLOCATEPARAM1LEN + idex]) << (idex << 3)) + timeOffset;
		}
		for(idex = 0;idex < SETSLOTALLOCATEPARAM3LEN;idex++)
		{
			sector = ((pSrioCmdBuffer[CMDPARAMOFFSET + SETSLOTALLOCATEELEMENTLEN*idexSlot + SETSLOTALLOCATEPARAM1LEN + SETSLOTALLOCATEPARAM2LEN + idex]) << (idex << 3)) + sector;
		}
		for(idex = 0;idex < SETSLOTALLOCATEPARAM4LEN;idex++)
		{
			weightBS[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + SETSLOTALLOCATEELEMENTLEN*idexSlot + SETSLOTALLOCATEPARAM1LEN + SETSLOTALLOCATEPARAM2LEN + SETSLOTALLOCATEPARAM3LEN + idex];
		}

		//Temporary test
		if(frameID == FrameIDFilter && idexSlot == 0 && RTxIndicate == 0)
		{
			System_printf("Error: Slot Allocate sector %d,RTx %d!\n", sector, RTxIndicate);
		}

		Write_FPGA_Reg(FPGA_REG_BF_COEF_TR_SE, 0x0);
		for(idex = 0;idex < SETSLOTALLOCATEPARAM4LEN;idex += 2)
		{
			Write_FPGA_Reg(FPGA_REG_BF_COEF_1CH_I + idex/2, (weightBS[idex + 1] << 8) + weightBS[idex]);
		}
		Write_FPGA_Reg(FPGA_REG_BF_COEF_USER_ID, (frameID & 0x1)?128 + idexSlot:idexSlot);
		Write_FPGA_Reg(FPGA_REG_DELAY_CTRL, timeOffset);
		Write_FPGA_Reg(FPGA_REG_SECTOR_RTX_CTRL, (RTxIndicate << 8) + sector);
		if(sector > SECTORNUM + 2)
		{
			System_printf("Error: Slot Allocate sector %d!\n", sector);
		}
		Write_FPGA_Reg(FPGA_REG_BF_COEF_TR_SE, 0x1);
	}
	Write_FPGA_Reg(FPGA_REG_BF_COEF_TR_SE, 0x0);

	return 0;
}

int SetPPSOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint16_t PPSSource = 0;
	uint16_t PPSResetVal = 0;
	uint32_t PPSDelay = 0;

	for(idex = 0;idex < SETPPSPARAM1LEN;idex++)
	{
		PPSSource = ((pSrioCmdBuffer[CMDPARAMOFFSET + idex]) << (idex << 3)) + PPSSource;
	}
	for(idex = 0;idex < SETPPSPARAM2LEN;idex++)
	{
		PPSResetVal = ((pSrioCmdBuffer[CMDPARAMOFFSET + SETPPSPARAM1LEN + idex]) << (idex << 3)) + PPSResetVal;
	}
	for(idex = 0;idex < SETPPSPARAM3LEN;idex++)
	{
		PPSDelay = ((pSrioCmdBuffer[CMDPARAMOFFSET + SETPPSPARAM1LEN + SETPPSPARAM2LEN + idex]) << (idex << 3)) + PPSDelay;
	}

	Write_FPGA_Reg(FPGA_REG_PPS_DELAY_H, (PPSDelay >> 16)  & 0xffff);
	Write_FPGA_Reg(FPGA_REG_PPS_DELAY_L, PPSDelay & 0xffff);

	Write_FPGA_Reg(FPGA_REG_PPS_RST_VAL, PPSResetVal);
	Write_FPGA_Reg(FPGA_REG_PPS_RST_EN, 0x0);
	Write_FPGA_Reg(FPGA_REG_PPS_RST_EN, 0x1);
	platform_delay(10);
	Write_FPGA_Reg(FPGA_REG_PPS_RST_EN, 0x0);

	return 0;
}

int AccessModeSelectOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t accessMode = 0;
	for(idex = 0;idex < ACCESSMODESELECTDATALEN;idex++)
	{
		accessMode = (pSrioCmdBuffer[CMDPARAMOFFSET + idex] << (idex*8)) + accessMode;
	}
	Write_FPGA_Reg(FPGA_REG_TDMA_EN, accessMode);

	return 0;
}

uint32_t DOAReqCnt = 0;

int StartDOACalcuOutCmdFrameHFunc()
{
	uint16_t idex = 0;
	uint8_t MACAddr[MACADRRLEN] = {0};
	uint8_t MACAddr_des[MACADRRLEN] = {0};
	uint8_t stationID = 0;

	UserIDQueueObj*    pUserIDQueue;

	uint8_t existFlag = 0;

	Queue_Elem* pQueueElem;

	for(idex = 0;idex < STARTDOACALCUPARAM1LEN;idex++)
	{
		MACAddr_des[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + idex];
	}
	for(idex = 0;idex < STARTDOACALCUPARAM1LEN;idex++)
	{
		MACAddr[idex] = pSrioCmdBuffer[CMDPARAMOFFSET + STARTDOACALCUPARAM1LEN + idex];
	}
	for(idex = 0;idex < STARTDOACALCUPARAM2LEN;idex++)
	{
		stationID = ((pSrioCmdBuffer[CMDPARAMOFFSET + STARTDOACALCUPARAM1LEN + STARTDOACALCUPARAM1LEN + idex]) << (idex << 3)) + stationID;
	}

	for(pQueueElem = Queue_head(hUserIDQueue);pQueueElem != (Queue_Elem*)hUserIDQueue;pQueueElem = Queue_next(pQueueElem))
	{
		if(((UserIDQueueObj*)pQueueElem)->id == stationID)
		{
			existFlag = 1;
		}
	}

	if(!Queue_empty(hUserIDQueueFree) && !existFlag)
	{
		pUserIDQueue = Queue_get(hUserIDQueueFree);
		pUserIDQueue->id = stationID;
		memcpy(pUserIDQueue->mac,MACAddr,USERMACADDRLEN);
		memcpy(pUserIDQueue->mac_des,MACAddr_des,USERMACADDRLEN);
		pUserIDQueue->cnt = 0;
		Queue_put(hUserIDQueue,(Queue_Elem*)pUserIDQueue);

		Semaphore_post(semUserDOARequest);
//		uint8_t weightBS[WEIGHTVECTORLEN] = {0};
//		GenRepDOAWeightInCmdFrame(MACAddr, 0, 0, weightBS);
	}

	DOAReqCnt++;

	return 0;
}

//For temporary test
//uint32_t idxDOATest = 0;
//int32_t doaEstiTest[10000] = {0};
//uint16_t spacialEstiTest[10000] = {0};
//int16_t weightCalcuTest[8*10000] = {0};

int16_t rxSigNoiseIFPGA[2048] = {0};
int16_t rxSigNoiseQFPGA[2048] = {0};

//uint16_t delayCal = 0;
//int16_t weightAdaptive[8];

uint8_t MACAddrDOA[MACADRRLEN] = {0};
uint8_t MACAddrDesDOA[MACADRRLEN] = {0};
uint16_t DOAEsti = 0xffff;
uint8_t sector = 0;
int DOAWeightsCalcuReport()
{
	uint32_t idxCh = 0;
	uint32_t idxSym = 0;
	uint32_t idxB = 0;
	uint32_t idxCpx = 0;


	sector = pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET - 1];

	if(sector > SECTORNUM)
	{
		System_printf("Error: Pilot receive sector %d!\n", sector);
		return -1;
	}

	for(idxCh = 0;idxCh < CHANNELNUM;idxCh++)
	{
		for(idxSym = 0;idxSym < SNAPSHOTNUM;idxSym++)
		{
			rxSigNoise[idxCh*SNAPSHOTNUM + idxSym].re =
					(int16_t)((pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM] << 8) +
							(pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 1]));
			rxSigNoise[idxCh*SNAPSHOTNUM + idxSym].im =
					(int16_t)((pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 2] << 8) +
							(pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET + idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 3]));
			rxSigNoiseIFPGA[idxCh*SNAPSHOTNUM + idxSym] =
								(int16_t)((pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM] << 8) +
										(pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 1]));
			rxSigNoiseQFPGA[idxCh*SNAPSHOTNUM + idxSym] =
					(int16_t)((pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET +idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 2] << 8) +
							(pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET + idxSym*ONESNAPSHOTBYTENUM + idxCh*ONESYMBOLBYTENUM + 3]));
		}
	}

#ifdef FINDOPTISYNC
#ifdef FIXEDPOINTDOAWEIGHTCAL
	FindOptiSyncFixedPointImplement_fixpt(rxSigNoise, PilotSequenceUpSample, &(PilotSequence[PILOTCIRCSHIFT]), &numSyncChannel, &circShiftSelect);
#else
	FindOptiSyncImplement(rxSigNoise, PilotSequenceUpSample, UPSAMPLETIME, LENSYNCSEARCH, &(PilotSequence[PILOTCIRCSHIFT]), &pilotSequenceSize, &numSyncChannel, &circShiftSelect);
#endif
#endif

	for(idxB = 0;idxB < MACADRRLEN;idxB++)
	{
		MACAddrDesDOA[idxB] = pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET+ SNAPSHOTNUM*ONESNAPSHOTBYTENUM + MACADDRDESBYTEOFFSET + idxB];
	}

	for(idxB = 0;idxB < MACADRRLEN;idxB++)
	{
		MACAddrDOA[idxB] = pSrioPilotBuffer[PILOTFRAMEBYTEOFFSET+ SNAPSHOTNUM*ONESNAPSHOTBYTENUM + MACADDRBYTEOFFSET + idxB];
	}
#ifdef FIXEDPOINTDOAWEIGHTCAL
	DoaEstimatorCBFFixedPointImplement_fixpt(recStvPartition, rxSigNoise, &(PilotSequence[PILOTCIRCSHIFT]), AzimuthScanAngles, 1, 0, spatialSpectrum, doasData);
	WeightCalcuMMSEFixedPointImplement_fixpt(rxSigNoise, &(PilotSequence[PILOTCIRCSHIFT]), DIAGONALLOADINGSNR, adaptiveRxWeights);
#else
	DoaEstimatorImplement(recStvPartition, rxSigNoise, &(PilotSequence[PILOTCIRCSHIFT]), AzimuthScanAngles, 1, 0, spatialSpectrum, doasData, &doasSize);
	WeightCalcuMMSEImplement(rxSigNoise, &(PilotSequence[PILOTCIRCSHIFT]), DIAGONALLOADINGSNR, adaptiveRxWeights);
#endif


	uint8_t weightBS[WEIGHTVECTORLEN] = {0};
	int16_t tmpConv = 0;
	for(idxCpx = 0,idxB = 0;idxCpx < CHANNELNUM;idxCpx++)
	{
		tmpConv = (adaptiveRxWeights[idxCpx].re)*WEIGHTQUANTIFULLSCALE;
		weightBS[idxB++] = tmpConv & 0xff;
		weightBS[idxB++] = (tmpConv >> 8) & 0xff;
		tmpConv = -(adaptiveRxWeights[idxCpx].im)*WEIGHTQUANTIFULLSCALE;
		weightBS[idxB++] = tmpConv & 0xff;
		weightBS[idxB++] = (tmpConv >> 8) & 0xff;
	}

	//For temporary test
//	delayCal = Read_FPGA_Reg(FPGA_REG_DELAY_CONFIG);
//	for(idxCpx = 0,idxB = 0;idxCpx < CHANNELNUM;idxCpx++)
//	{
//		weightAdaptive[idxB++] = (adaptiveRxWeights[idxCpx].re)*WEIGHTQUANTIFULLSCALE;
//		weightAdaptive[idxB++] = (adaptiveRxWeights[idxCpx].im)*WEIGHTQUANTIFULLSCALE;
//	}

	//For temporary test
//	if(idxDOATest >=10000)
//	{
//		;
//	}
//	else
//	{
//		doaEstiTest[idxDOATest] = doasData[0]*100;
//		spacialEstiTest[idxDOATest] = spatialSpectrum[(uint8_t)((doasData[0] + 30)/0.5)];
//		weightCalcuTest[idxDOATest*8 + 0] = (weightBS[1] << 8) + weightBS[0];
//		weightCalcuTest[idxDOATest*8 + 1] = (weightBS[3] << 8) + weightBS[2];
//		weightCalcuTest[idxDOATest*8 + 2] = (weightBS[5] << 8) + weightBS[4];
//		weightCalcuTest[idxDOATest*8 + 3] = (weightBS[7] << 8) + weightBS[6];
//		weightCalcuTest[idxDOATest*8 + 4] = (weightBS[9] << 8) + weightBS[8];
//		weightCalcuTest[idxDOATest*8 + 5] = (weightBS[11] << 8) + weightBS[10];
//		weightCalcuTest[idxDOATest*8 + 6] = (weightBS[13] << 8) + weightBS[12];
//		weightCalcuTest[idxDOATest*8 + 7] = (weightBS[15] << 8) + weightBS[14];
//		idxDOATest++;
//	}

	double DOADegree = (double)(doasData[0]/DOARESOLUTIONDIVIDER) + (sector + 1)*15;
	if(DOADegree < 0)
	{
		DOADegree += 360;
	}
	else if(DOADegree >= 360)
	{
		DOADegree -= 360;
	}

	DOAEsti = (uint16_t)(DOADegree*DOARESOLUTIONMULTIPLIER);

	return GenRepDOAWeightInCmdFrame(MACAddrDesDOA, MACAddrDOA, DOAEsti, sector, weightBS);
}

int ShakeOutCmdFrameHFunc()
{
	GenShakeInCmdFrame(SHAKES);
	dioSocketsSend((SHAKEFRAMELEN + SHAKEFRAMENUMPADD0 + 255)/256, SrioSendBuff, SHAKEFRAMELEN + SHAKEFRAMENUMPADD0);

	//delay for grab precise FPGA status
	System_printf("Handshaking...\n");
	platform_delay(10);
	if(Read_FPGA_Reg(FPGA_REG_SRIO_STAT) || Read_FPGA_Reg(FPGA_REG_SERDES_STAT))
	{
		if(Read_FPGA_Reg(FPGA_REG_SRIO_STAT))
		{
			while(Read_FPGA_Reg(FPGA_REG_SRIO_RES) != 0x1)Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x1);
			platform_delay(100000);
			while(Read_FPGA_Reg(FPGA_REG_SRIO_RES) != 0x0)Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x0);
			platform_delay(100000);
			while(Read_FPGA_Reg(FPGA_REG_SRIO_RES) != 0x1)Write_FPGA_Reg(FPGA_REG_SRIO_RES, 0x1);
			platform_delay(100000);
			System_printf("reset srio\n");
		}
		if(Read_FPGA_Reg(FPGA_REG_SERDES_STAT))
		{
			while(Read_FPGA_Reg(FPGA_REG_SERDES_RES) != 0x1)Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x1);
			platform_delay(100000);
			while(Read_FPGA_Reg(FPGA_REG_SERDES_RES) != 0x0)Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x0);
			platform_delay(100000);
			while(Read_FPGA_Reg(FPGA_REG_SERDES_RES) != 0x1)Write_FPGA_Reg(FPGA_REG_SERDES_RES, 0x1);
			platform_delay(100000);
			System_printf("reset serdes\n");
		}
	}
	else
	{
		if(!readyFlag)
		{
			Write_FPGA_Reg(FPGA_REG_RF_TR, 0x0699);
			Write_FPGA_Reg(FPGA_REG_RF_TR_CTRL, 0x0);//FPGA control
			readyFlag = 1;
			System_printf("Handshake passed\n");
		}
	}

	return 0;
}

//for test by Wayne
uint32_t numCSU = 0, numPUIU = 0;

Void TimerChannelStatusUp(UArg arg)
{
	GenTestChannelDetectInCmdFrame();
	numCSU++;
	//platform_delay(100000);//delay 500ms
}

Void TimerPhyUserInfoUp(UArg arg)
{
	GenTestPhyInfoReportInCmdFrame();
	numPUIU++;
}


