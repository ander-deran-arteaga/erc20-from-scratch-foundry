# ERC20 From Scratch (Foundry)

Build an ERC20 implementation **from scratch** in Solidity using **Foundry**, with a “Piscine-style” progression: tiny exercises → production-minded behavior → fuzz/invariant testing.

> **From scratch** here means: **no importing OpenZeppelin’s ERC20 implementation in `src/`**.  
> Interfaces/tools in tests are fine.

---

## Goals

- Understand ERC20 mechanics deeply (storage, events, allowances, edge cases).
- Write **high-signal Foundry tests** (unit + fuzz + invariants).
- Keep the repo reviewer-friendly: small commits, clear spec mapping, clean history.

---

## What’s included (current direction)

- `ScratchERC20` ERC20 implementation (no OZ ERC20).
- Foundry test suite.
- `forge-std` as a **git submodule** (keeps repo clean).

---

## Quickstart

### Requirements
- Foundry installed (`forge`, `cast`)

### Clone (with submodule)
```bash
git clone --recurse-submodules <your-repo-url>
cd erc20-from-scratch-foundry