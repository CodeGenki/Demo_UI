#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QSerialPortInfo>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlComponent>

#include "backend.h"
#include "serialport.h"

int main(int argc, char *argv[])
{
    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);

    qmlRegisterType<SerialPort>("io.qt.wpt.serialport", 1, 0, "SerialPort");

    QQuickStyle::setStyle("Material");

    foreach (const QSerialPortInfo &info, QSerialPortInfo::availablePorts()) {
        QStringList list;
        list << info.portName();
        QQuickView view;
        QQmlContext *ctxt = view.rootContext();
        ctxt->setContextProperty("comModel", QVariant::fromValue(list));
    }

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
