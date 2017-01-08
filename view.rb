require 'Qt'
require './enc_rand.rb'

MAIN_WINDOW_SIZE_X=640
MAIN_WINDOW_SIZE_Y=640

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

		images=Array.new
		fnames=["input.bmp","temp.bmp","result.bmp"]
		fnames.each do |f|
			img=ImgWidget.new
			img.load(f)
			images.push(img)
		end

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
		layout.add_layout(
			Qt::HBoxLayout.new() do
				addWidget(Qt::Label.new("鍵情報:"))
				addWidget(Qt::LineEdit.new)
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

	slots "encryption()"
	def encryption()
		puts "encrypt"
	end

	slots "decryption()"
	def decryption()
		puts "decrypt"
	end

end

app=Qt::Application.new(ARGV)
window=MainWidget.new
window.show
app.exec
