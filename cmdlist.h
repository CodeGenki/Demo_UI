#ifndef CMDLIST_H
#define CMDLIST_H

#define PWM_DIS         0x10
#define PWM_EN          0x11
#define REC_DIS         0x12
#define REC_EN          0x13
#define DAB_PRI_DIS     0x14
#define DAB_PRI_EN      0x15

#define DAB_FREQ_INC    0x20
#define DAB_FREQ_DEC    0x21
#define DAB_FREQ_SET    0x22

#define DAB_PHS_INC     0x28
#define DAB_PHS_DEC     0x29
#define DAB_PHS_SET     0x2A

#define I_LOOP_PR       0x40
#define I_OFFSET        0x41
#define FREQ_CHANGE     0x45 // Freq change

#endif // CMDLIST_H
