#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QObject>
#include <QSerialPort>

#define HEADER_FIRST_BYTE 85
#define HEADER_SECOND_BYTE -86

#define PACKET_INT16_NUM 8
#define PACKET_FLOAT_NUM 4
#define PACKET_BYTE_SIZE (4 + 4*PACKET_FLOAT_NUM + 2*PACKET_INT16_NUM)
#define PAYLOAD_BYTE_SIZE (4*PACKET_FLOAT_NUM + 2*PACKET_INT16_NUM)

class SerialPort : public QSerialPort
{
    Q_OBJECT
    Q_PROPERTY(QString V_Dc READ V_Dc WRITE setV_Dc NOTIFY V_Dc_Changed)
    Q_PROPERTY(QString I_Dc READ I_Dc WRITE setI_Dc NOTIFY I_Dc_Changed)

public:
    QString V_Dc();
    void setV_Dc(QString vdc);
    QString I_Dc();
    void setI_Dc(QString vdc);
    SerialPort(QObject *parent = 0);
    ~SerialPort();
    Q_INVOKABLE void closeSerialPort();
    Q_INVOKABLE void sendCmd(quint16 cmd, quint16 arg_1, float arg_2, float arg_3);
    Q_INVOKABLE void openSerialPort(QString name, QString baudRate, QString dataBits,
                                    QString parity, QString stopbits, QString flowControl);

    bool getFloat(float *,quint16 index);
    bool getInt16(qint16 *, quint16 index);
    Q_INVOKABLE QStringList getCOM();
    bool port_connected;

signals:
    void PacketReceived();
    void V_Dc_Changed();
    void I_Dc_Changed();

private slots:
    void readData();
    void getDataFromPacket();

private:
    QString m_V_Dc;
     QString m_I_Dc;
    SerialPort *serial;
    struct SerialPacket {
        qint16 data_int16[PACKET_INT16_NUM];
        float data_float[PACKET_FLOAT_NUM];
    };
    union PacketAssembly
    {
        struct SerialPacket packet;
        char bytes[PACKET_BYTE_SIZE];
//        char bytes[12];
    } packet_assembly;

    struct CmdPacket {
        quint16 header;
        quint16 cmd_word;
        float arg_2;
        float arg_3;
        quint16 arg_1;
        quint16 checksum;
    };
    union CmdAssembly
    {
        struct CmdPacket packet;
        quint16 word[8];
        char bytes[16];
    } cmd_assembly;

    void decodeByte(char read_byte);

    int decoder_state;
    quint16 payload_byte_counter;
    quint16 packet_count;

    //SettingsDialog *settings;
    QByteArray packet_buffer;

    QSerialPort *sp;
//    static const quint16 arduino_uno_vendor_id = 0x2341;
//    static const quint16 arduino_uno_product_id = 0x0001;
    QString mSerial_data;

};

#endif // SERIALPORT_H
