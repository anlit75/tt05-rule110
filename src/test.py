import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


@cocotb.test()
async def tb(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    # set the compare value
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    for cycle in range(180):
        if cycle == 1:
            first = ""
            for i in range(255, -1, -1):
                if i > 7:
                    first += "_"
                else:
                    if dut.ui_in[i].value == 1:
                        first += "#"
                    else:
                        first += "_"
            cocotb.log.info(first)

        elif 2 <= (cycle % 18) <= 17:
            graphic = ""
            data = dut.uo_out.value.binstr + dut.uio_out.value.binstr
            for i in range(15, -1, -1):
                if data[i] == '1':
                    graphic += "#"
                else:
                    graphic += "_"
            cocotb.log.info(graphic)
