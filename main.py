# This Python file uses the following encoding: utf-8
import sys
import os

from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSlot


class Loader(QObject):
    def __init__(self):
        super(Loader, self).__init__()

    @pyqtSlot(str, str, result=bool)
    def tobytes(self, path, destpath):
        self.destpath = destpath[8:]
        if os.path.isfile(path := path[8:]):
            with open(path, 'rb') as f:
                res = str(f.read().hex())
                length = len(res) // 10
                self.arr = [ res[i*length : (i+1)*length] for i in range(10)]
                self.path = path
                return True
        return False

    @pyqtSlot(int, result=str)
    def getbytes(self, index):
        if index == 9: self.copyfile()
        return self.arr[index]

    def copyfile(self):
        import shutil
        shutil.copyfile(self.path, os.path.join(self.destpath, os.path.basename(self.path)))


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    loader = Loader()

    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()
    ctx.setContextProperty('pyLoader', loader)

    engine.load(os.path.join(os.path.dirname(__file__), "main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
