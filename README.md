### Option 2: Enhanced Monospace ASCII Block

If you prefer the classic terminal/ASCII look inside a code box, copy this block:

```markdown
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
