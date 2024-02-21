import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  ProxyOwner,
  ProxyOwner__factory,
  ProxyAdmin__factory,
  ProxyAdmin,
  TransparentUpgradeableProxy,
  TransparentUpgradeableProxy__factory,
  ERC20,
  ERC20__factory,
} from '../../../types/generated'
import exp from 'constants'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Proxyowner.testSlot'))

describe('ProxyOwner', () => {
  let owner: SignerWithAddress
  let owner2: SignerWithAddress
  let user: SignerWithAddress
  let proxyOwner: ProxyOwner
  let proxyOwner2: ProxyOwner
  let proxyAdmin: ProxyAdmin
  let proxy: TransparentUpgradeableProxy
  let impl: ERC20
  let impl2: ERC20

  beforeEach(async () => {
    ;[owner, owner2, user] = await ethers.getSigners()
    impl = await new ERC20__factory(owner).deploy('Test', 'TEST')
    impl2 = await new ERC20__factory(owner).deploy('Test', 'TEST')
    proxyOwner = await new ProxyOwner__factory(owner).deploy()
    proxyOwner2 = await new ProxyOwner__factory(owner).deploy()
    proxyAdmin = await new ProxyAdmin__factory(owner).deploy()
    proxy = await new TransparentUpgradeableProxy__factory(owner).deploy(impl.address, proxyAdmin.address, '0x')
  })

  describe('proxyAdmin -> proxyOwner', async () => {
    it('transfers ownership', async () => {
      await proxyAdmin.connect(owner).changeProxyAdmin(proxy.address, proxyOwner.address)
      expect(await proxyOwner.getProxyAdmin(proxy.address)).to.equal(proxyOwner.address)
    })
  })

  describe('proxyOwner -> proxyOwner', async () => {
    beforeEach(async () => {
      await proxyAdmin.connect(owner).changeProxyAdmin(proxy.address, proxyOwner.address)
    })

    it('transfers ownership', async () => {
      await proxyOwner.connect(owner).transferOwnership(owner2.address)
      expect(await proxyOwner.owner()).to.equal(owner.address)
      expect(await proxyOwner.pendingOwner()).to.equal(owner2.address)

      await proxyOwner.connect(owner2).acceptOwnership()
      expect(await proxyOwner.owner()).to.equal(owner2.address)
      expect(await proxyOwner.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('transfers ownership of proxy', async () => {
      await proxyOwner.connect(owner).changeProxyAdmin(proxy.address, proxyOwner2.address)
      expect(await proxyOwner.getProxyAdmin(proxy.address)).to.equal(proxyOwner.address)
      expect(await proxyOwner.pendingAdmins(proxy.address)).to.equal(proxyOwner2.address)

      await proxyOwner2.connect(owner).acceptProxyAdmin(proxyOwner.address, proxy.address)
      expect(await proxyOwner2.getProxyAdmin(proxy.address)).to.equal(proxyOwner2.address)
      expect(await proxyOwner.pendingAdmins(proxy.address)).to.equal(ethers.constants.AddressZero)
    })

    it('reverts if not owner (change)', async () => {
      await expect(proxyOwner.connect(user).changeProxyAdmin(proxy.address, proxyOwner2.address)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      )
    })

    it('reverts if not owner (accept)', async () => {
      await expect(proxyOwner.connect(user).acceptProxyAdmin(proxyOwner2.address, proxy.address)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      )
    })

    it('reverts if not pending', async () => {
      await expect(proxyOwner2.connect(owner).acceptProxyAdmin(proxyOwner2.address, proxy.address)).to.be.revertedWith(
        'ProxyOwnerNotPendingAdminError',
      )
    })

    it('reverts if not pending (callback)', async () => {
      await expect(proxyOwner2.connect(owner).acceptProxyAdminCallback(proxy.address)).to.be.revertedWith(
        'ProxyOwnerNotPendingAdminError',
      )
    })
  })
})
