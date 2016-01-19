import os

f = open('licenseheader', 'r')
license = f.readlines()
f.close()

# Recursively visit *.ooc files in source/ and test/
for root, directories, filenames in os.walk('./source'):
	for filename in filenames:
		if filename.endswith('.ooc'):
			#filepath = './source/draw/gpu/GpuImage.ooc'
			filepath = os.path.join(root,filename)
			print(filepath)

			# Open file
			f = open(filepath, 'r+')
			lines = f.readlines()

			if len(lines) > 0:
				#print('\tNon-empty')
				index = 0
				f.close()
				f = open(filepath, 'w')

				# If it has old license...
				if (lines[0].startswith('/*') and not lines[0].startswith('/**')) or lines[0].startswith('//'):
					# ...remove it
					#print('\tHas old license')

					while (index < len(lines) and not '// along' in lines[index] and not '*/' in lines[index]) and ('//' in lines[index] or '*' in lines[index]):
						#print(' '+lines[index].rstrip())
						index += 1
					index += 1

				# Inject MIT license header (from LICENSE file)
				for lic in license:
					f.write(lic)

				# Make sure there is exactly one empty line after
				if lines[index].strip() != '':
					f.write('\n')

				# Put the rest (or all) of the file after the license
				while index < len(lines):
					f.write(lines[index])
					index += 1

			# Save
			f.close()
