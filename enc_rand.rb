class BmpEncrypt
	COL_MAX=256

	def initialize(seed)
		@random=Random.new(seed)
	end

	def Process(in_fname,out_fname,is_enc)
		File.open(in_fname,"rb") do |in_fp|
			ret=ReadHeader(in_fp)
			if ret then
				puts "ERROR: while reading header"
				puts ret
				exit
			end
			File.open(out_fname,"wb") do |out_fp|
				WriteHeader(out_fp)

				# read data and encryption
				for y in 1..@imgHeight do
					val=in_fp.read(3 * @imgWidth).unpack("c*")
					for x in 0..@imgWidth-1 do
						b=val[3*x+0].to_i
						g=val[3*x+1].to_i
						r=val[3*x+2].to_i

						# encryption or decryption
						if is_enc then
							b += @random.rand(0..COL_MAX-1)
							g += @random.rand(0..COL_MAX-1)
							r += @random.rand(0..COL_MAX-1)
						else
							b += COL_MAX - @random.rand(0..COL_MAX-1)
							g += COL_MAX - @random.rand(0..COL_MAX-1)
							r += COL_MAX - @random.rand(0..COL_MAX-1)
						end
						b %= COL_MAX
						g %= COL_MAX
						r %= COL_MAX

						out_fp.write([b,g,r].pack("c*"))
					end
					for i in 0..@padding-1 do
						in_fp.read(1)
						out_fp.write([0].pack("c*"))
					end
				end
			end
		end
	end
private
	def mget(fp,count)
		ret=0
		index=1
		for i in 1..count do
			read_val=fp.read(1).unpack("c*")[0].to_i
			ret+=read_val*index
			index*=256
		end
		return ret
	end

	def mput(fp,count,value)
		for i in 1..count do
			fp.write([value%256].pack("c*"))
			value/=256
		end
	end

	def ReadHeader(fp)
		if fp.read(2)!="BM" then
			return "Input file is not bitmap file"
		end
		@fileSize=mget(fp,4)# file size
		mget(fp,2);mget(fp,2)# skip reserved
		@offset=mget(fp,4)# offset
		@headerSize=mget(fp,4)# header size
		if @headerSize==40 then
			@imgWidth=mget(fp,4)
			@imgHeight=mget(fp,4)
			@plane=mget(fp,2)
			@bitCount=mget(fp,2)
			@compression=mget(fp,4)
			if @compression!=0 then
				return "bmp is compressed by "+compression.to_s
			end
			@sizeImage=mget(fp,4)
			@xPixPerlMeter=mget(fp,4)
			@yPixPerlMeter=mget(fp,4)
			@clrUsed=mget(fp,4)
			@cirImportant=mget(fp,4)
		elsif @headerSize.to_i==12 then
			return "This program is not supported OS/2"
		end
		@padding=4-@imgWidth*@bitCount/8%4
		if @padding==4 then
			@padding=0
		end
		return nil
	end

	def WriteHeader(fp)
		fp.write("BM")
		mput(fp,4,@fileSize)
		mput(fp,2,0)
		mput(fp,2,0)
		mput(fp,4,@offset)
		mput(fp,4,@headerSize)
		mput(fp,4,@imgWidth)
		mput(fp,4,@imgHeight)
		mput(fp,2,@plane)
		mput(fp,2,@bitCount)
		mput(fp,4,@compression)
		mput(fp,4,@sizeImage)
		mput(fp,4,@xPixPerlMeter)
		mput(fp,4,@yPixPerlMeter)
		mput(fp,4,@clrUsed)
		mput(fp,4,@cirImportant)
	end
end

enc=BmpEncrypt.new(0)
#start_time = Time.now
enc.Process("input.bmp","temp.bmp",true)
#puts "Time: #{Time.now - start_time}[sec]"
