### Architectural Role: Middleman Pipeline Stage

It is important to clarify that the **Pipeline Register is neither a true AXI Master nor a true AXI Slave**. Instead, it acts as an in-line bridge (or "Slice") positioned directly between them.

```text
+-------------------+          +-----------------------+          +-------------------+
|    AXI MASTER     |          |   PIPELINE REGISTER   |          |     AXI SLAVE     |
| (True Originator) |=========>|    (Bridge Stage)     |=========>| (True Recipient)  |
+-------------------+          +-----------------------+          +-------------------+
```
---

#### How Handshaking Works Inside the Register

The internal storage updates using a simple, two-rule check on every rising clock edge based on the state of the Master signals (named as Slave signals on our input port) and Slave signals (named as Master signals on our output port):

1. **Permission Check (`if (s_ready)`):** 
   Whenever our register is able to accept an update (`s_ready = 1`), we load the Master's valid signal (named as Slave signal `s_valid`) directly into `valid_reg`:
   * If the Master signal (named as Slave signal `s_valid`) is `1`, `valid_reg` becomes `1` (**Register Full**).
   * If the Master signal (named as Slave signal `s_valid`) is `0`, `valid_reg` becomes `0` (**Register Empty**).

2. **Data Capture (`if (s_valid)` inside `if (s_ready)`):** 
   If a true handshake occurs on the input side—meaning the Master signal (named as Slave signal `s_valid`) is `1` while our register is ready (`s_ready = 1`)—we latch the Master's data signal (named as Slave signal `s_data`) into `data_reg`.

```verilog
// Inside the sequential clock block:
if (s_ready) begin
    // Always update valid_reg when ready to track Full/Empty state
    valid_reg <= s_valid; 

    // Capture data payload ONLY when incoming data from Master is valid
    if (s_valid) begin
        data_reg <= s_data;
    end
end
```
---

### Interface Naming vs. Signal Behavior

Although port names appear inverted across the pipeline register, the **underlying signal behavior and data flow direction remain entirely unchanged**.

```text
+-----------------------+          +-----------------------------------+          +-----------------------+
|      AXI MASTER       |          |         PIPELINE REGISTER         |          |       AXI SLAVE       |
|  (Source / Producer)  |          |          (In the Middle)          |          |   (Sink / Consumer)   |
|                       |          |                                   |          |                       |
|   [ Outputs Data ]    |--s_data->| [  data_reg  ] --------- m_data ->|--s_data->|   [ Processes Data ]  |
|   [ Outputs Valid ]   |--s_valid>| [  valid_reg ] --------- m_valid->|--s_valid>|   [ Receives Valid ]  |
|   [ Reads Ready ]     |<-s_ready-| <----------------------- m_ready--|<-s_ready-|   [ Outputs Ready ]   |
|                       |          | s_ready = m_ready || !valid_reg   |          |                       |
+-----------------------+          +-----------------------------------+          +-----------------------+


