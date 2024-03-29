#include "serialport.h"
#include "qserialport.h"
#include "cmdlist.h"
#include <QDebug>
#include <QSerialPortInfo>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlProperty>

SerialPort::SerialPort(QObject *parent) :
    QSerialPort(parent)
{
    connect(this, SIGNAL(readyRead()), this, SLOT(readData()));
    decoder_state = 0;
    packet_count = 0;

    cmd_assembly.packet.header = 0x55aa;

    // Set initial voltage and current in GUI
    setV_Dc("0");
    setI_Dc("0");

    // Test visuals here
//    float V = 20.2121312f;
//    float I = 2.1345311f;
//    setV_Dc(QString::number(V, 'f', 2));
//    setI_Dc(QString::number(I, 'f', 2));



    connect(this,SIGNAL(PacketReceived()),this,SLOT(getDataFromPacket()));
}

SerialPort::~SerialPort()
{
//    delete settings;
}


float current_arr[100];
int leni = 0;
float ii = 0;

float voltage_arr[100];
int lenv = 0;
float vv = 0;

int counterMax = 20;
int counter = 0;
void SerialPort::getDataFromPacket()
{
    qint16 payload_int16[8];
    for(quint16 i=0;i<8;i++)
        this->getInt16(payload_int16+i,i);


    float payload_float[4];
    for(quint16 i=0;i<4;i++)
        this->getFloat(payload_float+i,i);

    float voltage = (0.2767f)*payload_float[1] - 2.1464f;
    float current = (0.0009f)*payload_float[2] - 0.0567f;
    if(voltage < 0)
        voltage = 0;
    if(current < 0)
        current = 0;

    // CURRENT AVERAGING
    leni++;
    ii = 0;
    if(leni >= 100) {
        leni = 0;
    }
    current_arr[leni] = current;
    int j = 0;
    for(j=0;j<leni;j++){
        ii += current_arr[j];
    }
    ii /= (j+1);
    current = ii;

    // VOLTAGE AVERAGING
    lenv++;
    vv = 0;
    if(lenv >= 100) {
        lenv = 0;
    }
    voltage_arr[lenv] = voltage;
    int k = 0;
    for(k=0;k<lenv;k++){
        vv += voltage_arr[k];
    }
    vv /= (k+1);
    voltage = vv;

    //setV_Dc(QString::number(payload_float[1]));
    counter++;
    if (counter > counterMax) {
        setV_Dc(QString::number(double(voltage), 'f', 2));
        setI_Dc(QString::number(double(current), 'f', 2));
        counter = 0;
    }

    qDebug() << payload_float[0] << voltage << current << payload_float[3];
}

QString SerialPort::V_Dc(){
    return m_V_Dc;
}


void SerialPort::setV_Dc(QString vdc){
    if(vdc == m_V_Dc)
        return;
    m_V_Dc = vdc;
    emit V_Dc_Changed();
}

QString SerialPort::I_Dc(){
    return m_I_Dc;
}


void SerialPort::setI_Dc(QString idc){
    if(idc == m_I_Dc)
        return;
    m_I_Dc = idc;
    emit I_Dc_Changed();
}

QStringList SerialPort::getCOM(){
    QStringList list;
    foreach (const QSerialPortInfo &info, QSerialPortInfo::availablePorts()) {
        list << info.portName();
        QQuickView view;
        QQmlContext *ctxt = view.rootContext();
        ctxt->setContextProperty("comModel", QVariant::fromValue(list));
    }
    return list;
}


void SerialPort::openSerialPort(QString name, QString baudRateSTR, QString dataBitsSTR,
                                QString paritySTR, QString stopbitsSTR, QString flowControlSTR)
{
//    qDebug() << name;
//    qDebug() << baudRate.toInt();
//    qDebug() << dataBits.toInt();
//    qDebug() << paritySTR;
//    qDebug() << stopbitsSTR;
//    qDebug() << flowControl; // always -1
    int baudRate = baudRateSTR.toInt();
    int dataBits = dataBitsSTR.toInt();
    int parity = -1;
    int stopbits = -1;
    int flowControl = -1;

    QSerialPort::Parity p = NoParity;
    QSerialPort::StopBits s = OneStop;
    QSerialPort::DataBits d = Data5;
    QSerialPort::FlowControl f = NoFlowControl;

    if(dataBitsSTR == "5"){
        d = Data5;
    }
    else if(dataBitsSTR == "6"){
        d = Data6;
    }
    else if(dataBitsSTR == "7"){
        d = Data7;
    }
    else if(dataBitsSTR == "8"){
        d = Data8;
    }

    if(paritySTR == "None"){
        p = NoParity;
        parity = 0;
    }
    else if (paritySTR == "Even") {
        p = EvenParity;
        parity = 2;
    }
    else if (paritySTR == "Odd") {
        p = OddParity;
        parity = 3;
    }
    else if (paritySTR == "Space") {
        p = SpaceParity;
        parity = 4;
    }
    else if (paritySTR == "Mark") {
        p = MarkParity;
        parity = 5;
    }

    if(stopbitsSTR == "1"){
        s = OneStop;
        stopbits = 1;
    }
    else if (stopbitsSTR == "1.5") {
        s = OneAndHalfStop;
        stopbits = 3;
    }
    else if (stopbitsSTR == "2") {
        s = TwoStop;
        stopbits = 2;
    }

    qDebug() << name;
    qDebug() << baudRate;
    qDebug() << d;
    qDebug() << p;
    qDebug() << s;
    qDebug() << f;
    this->setPortName(name);
    this->setBaudRate(baudRate);
    this->setDataBits(d);
    this->setParity(p);
    this->setStopBits(s);
    this->setFlowControl(f);

    port_connected = true;

    if(!this->open(QIODevice::ReadWrite)) {
//        QMessageBox msgBox;
//        msgBox.setText(this->errorString());
//        msgBox.exec();
        qDebug() << "ERROR CONNECTING";
        port_connected = false;
    }
}


void SerialPort::closeSerialPort()
{
    qDebug() << this->isOpen();
    if(this->isOpen()){
        this->close();
        port_connected = false;
    }
}


void SerialPort::sendCmd(quint16 cmd, quint16 arg_1, float arg_2, float arg_3)
{
    cmd_assembly.packet.cmd_word = cmd;
    cmd_assembly.packet.arg_1 = arg_1;
    cmd_assembly.packet.arg_2 = arg_2;
    cmd_assembly.packet.arg_3 = arg_3;
    quint16 checksum = 0;
    for(int i=0;i<7;i++)
        checksum += cmd_assembly.word[i];
    cmd_assembly.packet.checksum = checksum;
    this->write(cmd_assembly.bytes,16);
}

bool SerialPort::getFloat(float *p, quint16 index)
{
    if(index < PACKET_FLOAT_NUM)
    {
        *p = packet_assembly.packet.data_float[index];
        return true;
    }
    else
        return false;
}

bool SerialPort::getInt16(qint16 *p, quint16 index)
{
    if(index < PACKET_INT16_NUM)
    {
        *p = packet_assembly.packet.data_int16[index];
        return true;
    }
    else
        return false;
}

void SerialPort::readData()
{
    //qDebug() << "DD";
    char read_byte[256];
    qint64 bytes_count;
    bytes_count = this->read(read_byte,256);
    //qDebug() << bytes_count;
    for(qint64 i=0;i<bytes_count;i++)
        decodeByte(char(read_byte[i]));

}

void SerialPort::decodeByte(char read_byte)
{
    //qDebug() << decoder_state << read_byte;
    switch(decoder_state){
    case 0: // Standby. Waiting for header's first byte
    {
        if(read_byte == HEADER_FIRST_BYTE)
        {
            decoder_state = 1;
        }
        break;
    }
    case 1: // Waiting for header's second byte. If not received, return to standby state.
    {
        if(read_byte == HEADER_SECOND_BYTE)
        {
            decoder_state = 2;
            payload_byte_counter = 0;
        }
        else
            decoder_state = 0;
        break;
    }
    case 2: // Counter received. Start to receive payload. Switch to next state at the last bytes of payload.
    {
        if(payload_byte_counter<(PAYLOAD_BYTE_SIZE-1))
        {
            packet_assembly.bytes[payload_byte_counter] = read_byte;
            payload_byte_counter++;
        }
        else if(payload_byte_counter==(PAYLOAD_BYTE_SIZE-1)) // Last byte of data, need to change to the next state.
        {
            packet_assembly.bytes[payload_byte_counter] = read_byte;
            decoder_state = 3;
        }
        else
            decoder_state = 0;
        break;
    }
    case 3: // Waiting for checksum's first byte.
    {
        decoder_state = 4;
        break;
    }
    case 4: // Waiting for checksum's second byte.
    {
        decoder_state = 0;
        //qDebug() << packet_count++;
        emit PacketReceived();
        break;
    }
    default:
    {
        decoder_state = 0;
        break;
    }
    }
}
