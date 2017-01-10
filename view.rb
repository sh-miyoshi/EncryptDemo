require 'Qt'
require './enc_rand.rb'

MAIN_WINDOW_SIZE_X=640
MAIN_WINDOW_SIZE_Y=640
IMAGE_FILE_NAMES=["input.bmp","temp.bmp","result.bmp"]

class ImgWidget < Qt::Widget
	def initialize
		super
	end

	def load(fname)
		@image=Qt::Image.new(fname)
		if ! @image.isNull then
			size=MAIN_WINDOW_SIZE_X/3-2
			@image = @image.scaled(size,size)
		end
	end

	def paintEvent(e)
		@paint=Qt::Painter.new(self)
		@paint.drawImage(0,0,@image)
		@paint.end
	end
end

class MainWidget < Qt::Widget
	def initialize
		super

		@seed=0

		images=Array.new
		IMAGE_FILE_NAMES.each do |f|
			img=ImgWidget.new
			img.load(f)
			images.push(img)
		end
		@cimgs=images

		bt_enc=Qt::PushButton.new('暗号化')
		bt_dec=Qt::PushButton.new('復号')
		connect(bt_enc,SIGNAL("clicked()"),self,SLOT("encryption()"))
		connect(bt_dec,SIGNAL("clicked()"),self,SLOT("decryption()"))

		layout=Qt::VBoxLayout.new
		layout.add_layout(
			Qt::HBoxLayout.new() do
				images.each do |i|
					addWidget(i)
				end
			end
		)

		key_info=Qt::LineEdit.new
		connect(key_info,SIGNAL("textChanged(QString)"),self,SLOT("set_seed(QString)"))

		layout.add_layout(
			Qt::HBoxLayout.new() do
				addWidget(Qt::Label.new("鍵情報:"))
				addWidget(key_info)
			end
		)
		layout.add_layout(
			Qt::HBoxLayout.new() do
				addWidget(bt_enc)
				addWidget(bt_dec)
			end
		)
		self.setLayout(layout)

		resize(MAIN_WINDOW_SIZE_X,MAIN_WINDOW_SIZE_Y)
	end

	slots "set_seed(QString)"
	def set_seed(str)
		@seed=str.to_i
	end

	slots "encryption()"
	def encryption()
		enc=BmpEncrypt.new(@seed)
		enc.Process(IMAGE_FILE_NAMES[0],IMAGE_FILE_NAMES[1],true)
		@cimgs[1].load(IMAGE_FILE_NAMES[1])
		@cimgs[1].update
	end

	slots "decryption()"
	def decryption()
		enc=BmpEncrypt.new(@seed)
		enc.Process(IMAGE_FILE_NAMES[1],IMAGE_FILE_NAMES[2],false)
		@cimgs[2].load(IMAGE_FILE_NAMES[2])
		@cimgs[2].update
	end

end

app=Qt::Application.new(ARGV)
window=MainWidget.new
window.show
app.exec
